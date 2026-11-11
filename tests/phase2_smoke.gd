extends SceneTree

var failed := false

func _initialize() -> void:
	call_deferred("run_test")

func check(condition: bool, message: String) -> void:
	if not condition:
		push_error("FAIL: " + message)
		failed = true
	else:
		print("PASS: " + message)

func run_test() -> void:
	var scene := load("res://scenes/world/Foundation.tscn") as PackedScene
	check(scene != null, "Main scene loads")
	if scene == null:
		return
	var world := scene.instantiate()
	# Keep tests independent of network and repository state.
	var test_update_config = world.get_node("Overlay/UpdateNotice").config.duplicate()
	test_update_config.enabled = false
	world.get_node("Overlay/UpdateNotice").config = test_update_config
	world.get_node("LocalSaveManager").enabled = false # Isolate gameplay tests from real local saves.
	root.add_child(world)
	var player := world.get_node("Player") as CharacterBody3D
	var controls := world.get_node("Overlay/TouchControls") as Control
	check(player != null and controls != null, "Player and controls exist")
	for i in range(60):
		await physics_frame
	check(player.is_on_floor(), "Player lands on ground")
	var start := player.global_position
	player.set_touch_move(Vector2(0, -1))
	for i in range(40):
		await physics_frame
	player.set_touch_move(Vector2.ZERO)
	check(player.global_position.distance_to(start) > 0.5, "Movement advances the player")
	var animator := player.get_node("Visual/KnightModel/AnimationPlayer") as AnimationPlayer
	check(animator != null and animator.current_animation == "Run", "Rigged character uses run animation")
	player.queue_jump()
	for i in range(4):
		await physics_frame
	check(player.velocity.y > 0, "Jump gives upward velocity")
	var pivot := player.get_node("CameraPivot") as Node3D
	var old_yaw := pivot.rotation.y
	player.look_by(Vector2(30, 0))
	check(absf(pivot.rotation.y - old_yaw) > 0.01, "Camera responds to look input")
	var press := InputEventScreenTouch.new()
	press.index = 4
	press.pressed = true
	press.position = controls.get_global_transform_with_canvas() * (controls._stick_center() + Vector2(controls._radius() * 0.5, 0))
	controls._input(press)
	check(player.touch_move.x > 0.4, "Joystick touch reaches player")
	press.pressed = false
	controls._input(press)
	check(player.touch_move == Vector2.ZERO, "Joystick release stops touch movement")
	print("Arrow key codes: ", KEY_LEFT, " ", KEY_RIGHT, " ", KEY_UP, " ", KEY_DOWN)
	print("Phase 2 headless smoke checks finished")
	world.queue_free()
	quit(1 if failed else 0)
