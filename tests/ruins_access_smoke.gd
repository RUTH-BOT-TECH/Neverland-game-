extends SceneTree
## Exercises the actual character controller along the street-to-ruins route.
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
	var world := (load("res://scenes/world/Foundation.tscn") as PackedScene).instantiate()
	world.get_node("LocalSaveManager").enabled = false
	var notice = world.get_node("Overlay/UpdateNotice")
	notice.config = notice.config.duplicate()
	notice.config.enabled = false
	root.add_child(world)
	var ruins = world.get_node("Ruins")
	var art = ruins.get_node("RuinDetails")
	var player = world.get_node("Player")
	var quest = world.get_node("QuestManager")
	var ui = world.get_node("Overlay/QuestUI")
	var marker = ruins.get_node("TestMarker")
	check(art.find_children("Column_*", "Node3D", false, false).size() == 4, "Four decorated columns exist")
	check(art.find_children("EmptyInlay*", "MeshInstance3D", false, false).size() == 5, "Five decorative inlays exist")
	check(art.find_children("*", "CollisionShape3D", true, false).is_empty(), "Decorative ruins add no invisible collisions")
	check(marker.mesh is ArrayMesh and ruins.get_node("MarkerLabel").text == "SURVEY MARKER", "Quest marker remains distinct and labelled")
	quest.report_event("speak_to_mira")
	player.global_position = Vector3(0, 0.1, -8)
	player.velocity = Vector3.ZERO
	player.camera_pivot.rotation.y = 0
	player.set_touch_move(Vector2(1, 0))
	for i in range(150):
		await physics_frame
	player.set_touch_move(Vector2.ZERO)
	for i in range(5): await physics_frame
	await process_frame
	check(player.global_position.x > 8.0, "Player can cross from street through houses to the ruins")
	check(ui.examine_button.visible, "Marker is in interaction range from the platform edge")
	ui.examine_marker()
	check(quest.status == quest.QuestStatus.COMPLETED and quest.session_xp == 25, "Quest completes after walking to the ruins")
	world.free()
	quit(1 if failed else 0)
