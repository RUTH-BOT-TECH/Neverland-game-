extends SceneTree
## Verify local story progression, stable open conversations and safe interaction.
var failed := false
func _initialize() -> void:
	call_deferred("run_test")

func check(ok: bool, message: String) -> void:
	if ok:
		print("PASS: ", message)
	else:
		failed = true
		push_error("FAIL: " + message)

func run_test() -> void:
	var world := (load("res://scenes/world/Foundation.tscn") as PackedScene).instantiate()
	world.get_node("LocalSaveManager").enabled = false
	var notice = world.get_node("Overlay/UpdateNotice")
	notice.config = notice.config.duplicate()
	notice.config.enabled = false
	root.add_child(world)
	var player = world.get_node("Player")
	var npc = world.get_node("VillageHerald")
	var ui = world.get_node("Overlay/DialogueUI")
	var quest = world.get_node("QuestManager")
	var guardian = world.get_node("AshenShrine/Guardian")
	var orb = world.get_node("AshenShrine/FlameOrb")
	var inventory = world.get_node("OrbInventory")
	player.global_position = npc.global_position + Vector3(1, 0, 0)
	await process_frame
	check(npc.current_dialogue() == npc.dialogue, "Opening dialogue selected before quest starts")
	ui.open_dialogue()
	ui.close_dialogue()
	check(quest.objective_index == 0, "Closing opening early does not advance quest")
	ui.open_dialogue()
	for i in range(npc.dialogue.lines.size()): ui.advance_dialogue()
	check(quest.objective_index == 1 and npc.current_dialogue() == npc.survey_dialogue, "Opening completion advances to survey reminder")
	ui.open_dialogue()
	check(ui.line_label.text == npc.survey_dialogue.lines[0], "Survey reminder is shown")
	check(quest.report_event("inspect_survey_marker"), "Survey objective advances")
	check(ui._active_dialogue == npc.survey_dialogue, "Open conversation remains stable if progress changes")
	ui.close_dialogue()
	check(npc.current_dialogue() == npc.trial_dialogue, "Trial instructions selected after survey")
	ui.open_dialogue()
	for i in range(npc.trial_dialogue.lines.size()): ui.advance_dialogue()
	check(quest.session_xp == 25 and quest.objective_index == 2, "Later conversations do not grant quest rewards twice")
	guardian.take_damage(100)
	check(guardian.defeated and npc.current_dialogue() == npc.guardian_defeated_dialogue, "Guardian defeat selects Orb collection reminder")
	player.global_position = orb.global_position + Vector3(1, -1.75, 0)
	check(orb.try_collect() and inventory.has_orb(&"orb_flame"), "Flame Orb collected")
	check(npc.current_dialogue() == npc.flame_recovered_dialogue, "Flame Orb selects the story revelation")
	player.global_position = npc.global_position + Vector3(1, 0, 0)
	ui.open_dialogue()
	check(ui.line_label.text == npc.flame_recovered_dialogue.lines[0], "Revelation can be opened after collection")
	ui.advance_dialogue()
	check(ui.line_label.text.contains("Apart"), "Ancient inscription appears")
	for i in range(3): ui.advance_dialogue()
	check(not ui._in_dialogue and quest.session_xp == 25, "Revelation ends without extra rewards")
	player.set_controls_enabled(false)
	ui.open_dialogue()
	check(not ui._in_dialogue, "Dialogue cannot open while other controls are disabled")
	player.set_controls_enabled(true)
	player.global_position = npc.global_position + Vector3(20, 0, 0)
	ui.open_dialogue()
	check(not ui._in_dialogue, "Dialogue rechecks distance instead of stale button visibility")
	world.free()
	quit(1 if failed else 0)
