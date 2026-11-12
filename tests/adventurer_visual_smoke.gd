extends SceneTree
## Character integration checks; rendered appearance and Android performance
## must be checked separately on real devices.
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
	var model = player.get_node("Visual/KnightModel")
	var animator: AnimationPlayer = model.get_node("AnimationPlayer")
	var meshes := model.find_children("*", "MeshInstance3D", true, false)
	check(meshes.size() == 1 and meshes[0].mesh.get_surface_count() > 0, "Adventurer model and skinned mesh load")
	check(is_equal_approx(model.scale.x, 1.0) and is_equal_approx(model.rotation.y, PI), "Model uses real-world scale and faces controller direction")
	check(animator.has_animation("Idle") and animator.has_animation("Run") and animator.has_animation("Sword slash"), "Idle, run and sword clips import")
	for i in range(30): await physics_frame
	check(animator.current_animation == "Idle", "Idle clip plays while standing")
	player.set_touch_move(Vector2(0, -1))
	for i in range(30): await physics_frame
	check(animator.current_animation == "Run", "Run clip plays while moving")
	player.set_touch_move(Vector2.ZERO)
	for i in range(30): await physics_frame
	check(player.get_node("Combat").try_attack(), "Attack remains available")
	for i in range(3): await physics_frame
	check(animator.current_animation == "Sword slash" and animator.is_playing(), "Sword slash plays for melee")
	check(is_equal_approx(animator.speed_scale, 1.35), "Sword animation fits the combat cooldown")
	for i in range(65): await physics_frame
	check(animator.current_animation == "Idle" and is_equal_approx(animator.speed_scale, 1.0), "Idle resumes after the attack")
	var herald = world.get_node("VillageHerald")
	var herald_animation: AnimationPlayer = herald.get_node("Model/Peasant/AnimationPlayer")
	check(herald_animation.has_animation("Idle") and herald_animation.has_animation("Walk"), "Mira's new model has idle and walk clips")
	herald._patrol_time = 1.2
	herald._process(0.01)
	check(herald_animation.current_animation == "Walk" and is_equal_approx(herald.model.rotation.y, PI / 2.0), "Mira faces and animates in her patrol direction")
	herald.set_talking(true)
	check(herald_animation.current_animation == "Idle", "Mira stops walking while speaking")
	world.free()
	quit(1 if failed else 0)
