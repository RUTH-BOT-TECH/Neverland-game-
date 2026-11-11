extends SceneTree

var failed := false

func _initialize() -> void:
	call_deferred("run_test")

func check(condition: bool, message: String) -> void:
	if condition:
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
	world.get_node("LocalSaveManager").enabled = false # Isolate gameplay tests from real local saves.
	root.add_child(world)
	var player = world.get_node("Player")
	var npc = world.get_node("VillageHerald")
	var ui = world.get_node("Overlay/DialogueUI")
	await process_frame
	await process_frame
	check(not ui.talk_button.visible, "Talk is hidden when too far away")
	ui.open_dialogue()
	check(not ui._in_dialogue, "Cannot open dialogue from far away")
	player.global_position = npc.global_position + Vector3(1, 0.1, 0)
	player.velocity = Vector3.ZERO
	await process_frame
	await process_frame
	check(ui.talk_button.visible, "Talk becomes available near the herald")
	ui.talk_button.emit_signal("pressed")
	check(ui._in_dialogue and ui.panel.visible, "Dialogue opens")
	check(not player.controls_enabled and npc._talking, "Movement and patrol pause during dialogue")
	check(ui.speaker.text == "Mira, Guild Herald" and ui.line_label.text == npc.dialogue.lines[0], "First story line and speaker are shown")
	player.set_touch_move(Vector2(1, 0))
	check(player.touch_move == Vector2.ZERO, "Player ignores movement input during dialogue")
	ui.next_button.emit_signal("pressed")
	check(ui.line_label.text == npc.dialogue.lines[1], "Next button advances dialogue")
	ui.get_node("DialoguePanel/Margin/Contents/Buttons/CloseButton").emit_signal("pressed")
	check(not ui.panel.visible and player.controls_enabled and not npc._talking, "Close resumes controls and patrol")
	await process_frame
	var e := InputEventAction.new()
	e.action = "interact"
	e.pressed = true
	ui._unhandled_input(e)
	check(ui._in_dialogue, "Interact action opens dialogue")
	for i in range(npc.dialogue.lines.size()):
		ui.advance_dialogue()
	check(not ui._in_dialogue and player.controls_enabled, "Final line finishes dialogue")
	await process_frame
	ui.open_dialogue()
	player.global_position += Vector3(10, 0, 0)
	await process_frame
	await process_frame
	check(not ui._in_dialogue and player.controls_enabled, "Moving out of range closes dialogue")
	world.queue_free()
	quit(1 if failed else 0)
