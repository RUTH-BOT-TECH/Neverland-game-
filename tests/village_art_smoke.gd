extends SceneTree
## Checks the procedural village's structural layout; not a visual or device test.
func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var village := (load("res://scenes/world/Village.tscn") as PackedScene).instantiate() as Node3D
	root.add_child(village)
	await process_frame
	var houses := village.get_node("Houses")
	assert(houses.get_child_count() == 8, "Eight houses expected")
	for house in houses.get_children():
		assert(house.get_node_or_null("DetailedDoor") != null)
		assert(house.get_node_or_null("GableFront") != null)
		assert(house.get_node_or_null("GableBack") != null)
		assert(not house.find_children("*", "CollisionShape3D", false, false).is_empty())
	for tree in village.get_node("Trees").get_children():
		assert(Vector2(tree.position.x - 10.0, tree.position.z + 8.0).length() >= 6.5)
	for kind in range(3):
		var meadow := village.get_node("Meadow_%d" % kind) as MultiMeshInstance3D
		assert(meadow.multimesh.instance_count == [500, 180, 55][kind])
		assert(meadow.multimesh.mesh != null)
		# The headless dummy renderer does not return stored instance transforms.
		if DisplayServer.get_name() == "headless":
			continue
		for i in range(meadow.multimesh.instance_count):
			var p := meadow.multimesh.get_instance_transform(i).origin
			assert(absf(p.x) >= 2.6, "Street must stay visually clear")
			assert(not (absf(p.x - 10.0) < 3.5 and p.z > -11.5 and p.z < -3.5), "Survey platform must stay visually clear")
	print("Village art smoke passed: houses, foliage batches and tree placement (meadow placement requires graphics renderer)")
	village.queue_free()
	await process_frame
	quit()
