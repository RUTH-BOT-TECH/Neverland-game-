extends SceneTree

var failed := false
var path := "user://eldoria_test_checkpoint_%d.json" % OS.get_process_id()

func _initialize() -> void:
	call_deferred("run_test")

func check(ok: bool, message: String) -> void:
	if ok:
		print("PASS: ", message)
	else:
		failed = true
		push_error("FAIL: " + message)

func new_world() -> Node:
	var world := (load("res://scenes/world/Foundation.tscn") as PackedScene).instantiate()
	world.get_node("LocalSaveManager").save_path = path
	var notice = world.get_node("Overlay/UpdateNotice")
	notice.config = notice.config.duplicate()
	notice.config.enabled = false
	root.add_child(world)
	return world

func clear_test_files() -> void:
	for suffix in ["", ".bak", ".tmp", ".damaged"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))

func write_text(file_path: String, text: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(text)
	file.close()

func run_test() -> void:
	clear_test_files()
	var world := new_world()
	var manager = world.get_node("QuestManager")
	var saver = world.get_node("LocalSaveManager")
	check(not FileAccess.file_exists(path), "No save created before a milestone")
	manager.report_event("speak_to_mira")
	check(FileAccess.file_exists(path) and not saver.writes_blocked, "Quest progress writes a checkpoint")
	world.free()
	world = new_world()
	manager = world.get_node("QuestManager")
	saver = world.get_node("LocalSaveManager")
	check(manager.objective_index == 1 and manager.session_xp == 0 and world.get_node("Overlay/QuestUI/Tracker/Margin/Content/Objective").text.contains("Examine"), "Partial quest and tracker restore without extra XP")
	manager.report_event("inspect_survey_marker")
	check(manager.session_xp == 25 and FileAccess.file_exists(path + ".bak"), "Quest completion saves and retains previous checkpoint")
	var guardian = world.get_node("AshenShrine/Guardian")
	guardian.take_damage(100)
	check(guardian.defeated, "Guardian defeat is checkpointed")
	world.free()
	world = new_world()
	manager = world.get_node("QuestManager")
	guardian = world.get_node("AshenShrine/Guardian")
	var orb = world.get_node("AshenShrine/FlameOrb")
	var player = world.get_node("Player")
	check(manager.session_xp == 25 and guardian.defeated and not orb.is_collected, "Completed quest and defeated guardian restore before collection")
	player.global_position = orb.global_position + Vector3(1, -1.75, 0)
	check(orb.try_collect(), "Orb collection writes a checkpoint")
	world.free()
	world = new_world()
	manager = world.get_node("QuestManager")
	guardian = world.get_node("AshenShrine/Guardian")
	orb = world.get_node("AshenShrine/FlameOrb")
	var inventory = world.get_node("OrbInventory")
	check(manager.session_xp == 25 and guardian.defeated and orb.is_collected and not orb.visual.visible and inventory.orb_count() == 1, "Orb and reward restore once; collected visual hidden")
	check(world.get_node("Overlay/FlameTrialUI").info.text.contains("1/5"), "Restored HUD shows Orb count")
	check(not inventory.add_unique_orb(&"orb_flame") and not orb.try_collect(), "Restored Orb cannot be collected twice")
	world.free()
	# A torn primary falls back to the previous validated checkpoint.
	write_text(path, "{broken")
	world = new_world()
	saver = world.get_node("LocalSaveManager")
	check(not saver.writes_blocked and saver.last_error.contains("Recovered") and world.get_node("AshenShrine/Guardian").defeated and world.get_node("OrbInventory").orb_count() == 0, "Corrupt primary recovers previous checkpoint with a warning")
	check(saver.save_now() and FileAccess.file_exists(path + ".damaged"), "Recovered save preserves damaged file before replacing it")
	world.free()
	clear_test_files()
	write_text(path, "{bad")
	world = new_world()
	saver = world.get_node("LocalSaveManager")
	world.get_node("QuestManager").report_event("speak_to_mira")
	check(saver.writes_blocked and FileAccess.get_file_as_string(path) == "{bad" and world.get_node("Overlay/SaveWarning").visible, "Unrecoverable save is not overwritten and player sees warning")
	world.free()
	clear_test_files()
	write_text(path, '{"version": 999}')
	world = new_world()
	saver = world.get_node("LocalSaveManager")
	world.get_node("QuestManager").report_event("speak_to_mira")
	check(saver.writes_blocked and FileAccess.get_file_as_string(path).contains("999"), "Future-version save is not overwritten")
	world.free()
	clear_test_files()
	write_text(path, '{"version":1,"quest_id":"heralds_warning","objective_index":0,"guardian_defeated":true,"owned_orbs":["orb_flame"]}')
	world = new_world()
	check(world.get_node("LocalSaveManager").writes_blocked and world.get_node("OrbInventory").orb_count() == 0, "Inconsistent checkpoint is rejected")
	world.free()
	clear_test_files()
	print("Local save smoke checks finished")
	quit(1 if failed else 0)
