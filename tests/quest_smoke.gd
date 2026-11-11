extends SceneTree

var failed := false

func _initialize() -> void:
	call_deferred("run_test")

func check(value: bool, message: String) -> void:
	if value:
		print("PASS: ", message)
	else:
		failed = true
		push_error("FAIL: " + message)

func run_test() -> void:
	var packed := load("res://scenes/world/Foundation.tscn") as PackedScene
	if packed == null:
		push_error("Main scene did not load")
		quit(1)
		return
	var world := packed.instantiate()
	# Keep tests independent of network and repository state.
	var test_update_config = world.get_node("Overlay/UpdateNotice").config.duplicate()
	test_update_config.enabled = false
	world.get_node("Overlay/UpdateNotice").config = test_update_config
	root.add_child(world)
	var player = world.get_node("Player")
	var npc = world.get_node("VillageHerald")
	var dialogue = world.get_node("Overlay/DialogueUI")
	var ui = world.get_node("Overlay/QuestUI")
	var manager = world.get_node("QuestManager")
	var marker = world.get_node("Ruins/TestMarker")
	await process_frame
	await process_frame
	check(manager.is_expecting("speak_to_mira"), "First objective starts active")
	check(ui.objective.text == "Speak with Mira, the guild herald", "Tracker shows first objective")
	check(not manager.report_event("inspect_survey_marker"), "Out-of-order event is rejected")
	player.global_position = npc.global_position + Vector3(1, 0.1, 0)
	player.velocity = Vector3.ZERO
	await process_frame
	await process_frame
	dialogue.open_dialogue()
	dialogue.close_dialogue()
	check(manager.objective_index == 0, "Closing dialogue early does not complete objective")
	await process_frame
	dialogue.open_dialogue()
	for i in range(npc.dialogue.lines.size()):
		dialogue.advance_dialogue()
	check(manager.is_expecting("inspect_survey_marker"), "Finishing Mira's dialogue activates second objective")
	check(not manager.report_event("speak_to_mira"), "Repeating the first event does not skip objective")
	check(ui.objective.text == "Examine the blue marker at the ruins", "Tracker shows second objective")
	ui.examine_marker()
	check(manager.session_xp == 0, "Marker cannot be examined at a distance")
	player.global_position = marker.global_position + Vector3(1, -1.85, 0)
	player.velocity = Vector3.ZERO
	await process_frame
	await process_frame
	check(ui.examine_button.visible, "Examine button appears near marker")
	var interact := InputEventAction.new()
	interact.action = "interact"
	interact.pressed = true
	root.push_input(interact, true)
	await process_frame
	check(manager.status == manager.QuestStatus.COMPLETED, "Interact action completes quest")
	check(manager.session_xp == 25 and ui.objective.text.contains("Completed"), "Quest awards 25 session XP and updates tracker")
	check(not manager.report_event("inspect_survey_marker") and manager.session_xp == 25, "Repeated completion does not duplicate XP")
	world.queue_free()
	quit(1 if failed else 0)
