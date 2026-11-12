extends SceneTree
## Tests the combat warning against the actual local damage radius.
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
	var guardian = world.get_node("AshenShrine/Guardian")
	var player = world.get_node("Player")
	var vitals = player.get_node("Vitals")
	var quest = world.get_node("QuestManager")
	guardian.set_physics_process(false)
	player.global_position = guardian.global_position + Vector3(2, 0, 0)
	guardian._physics_process(0.1)
	check(not guardian.attack_warning.visible and guardian.windup_left == 0, "Locked guardian does not telegraph or attack")
	quest.report_event("speak_to_mira")
	quest.report_event("inspect_survey_marker")
	guardian._physics_process(0.1)
	check(guardian.attack_warning.visible and guardian.windup_left == guardian.windup_seconds, "Danger area appears when wind-up starts")
	check(is_equal_approx(guardian.attack_warning.scale.x, guardian.attack_range) and is_equal_approx(guardian.attack_warning.scale.z, guardian.attack_range), "Warning edge matches damage radius")
	guardian.take_damage(20)
	check(guardian.name_label.text.contains("MOVE AWAY") and guardian.attack_warning.visible, "Taking a hit does not hide the active warning")
	player.set_controls_enabled(false)
	var frozen: float = guardian.windup_left
	guardian._physics_process(3.0)
	check(guardian.windup_left == frozen and guardian.attack_warning.visible and vitals.health == 100, "Dialog pause keeps the warning and timer in sync")
	player.set_controls_enabled(true)
	player.global_position = guardian.global_position + Vector3(guardian.attack_range + 0.2, 0, 0)
	guardian._physics_process(guardian.windup_seconds + 0.01)
	check(vitals.health == 100 and not guardian.attack_warning.visible, "Stepping outside the marked radius avoids damage")
	guardian._physics_process(guardian.cooldown_seconds + 0.01)
	player.global_position = guardian.global_position + Vector3(1, 0, 0)
	guardian._physics_process(0.01)
	guardian._physics_process(guardian.windup_seconds + 0.01)
	check(vitals.health == 85 and not guardian.attack_warning.visible, "Staying inside the danger zone takes damage")
	guardian._physics_process(guardian.cooldown_seconds + 0.01)
	guardian._physics_process(0.01)
	check(guardian.attack_warning.visible, "Warning can start again after cooldown")
	vitals.take_damage(999)
	check(not guardian.attack_warning.visible and guardian.windup_left == 0 and guardian.health == guardian.max_health, "Respawn resets and hides the warning")
	player.global_position = guardian.global_position + Vector3(1, 0, 0)
	guardian._physics_process(0.01)
	guardian.take_damage(guardian.max_health)
	check(guardian.defeated and not guardian.attack_warning.visible, "Defeating the guardian cancels its warning")
	guardian.restore_defeated()
	check(not guardian.attack_warning.visible, "Restoring a defeated guardian keeps the warning hidden")
	world.free()
	# Exercise actual movement and physics timing, not just repositioning.
	world = (load("res://scenes/world/Foundation.tscn") as PackedScene).instantiate()
	world.get_node("LocalSaveManager").enabled = false
	notice = world.get_node("Overlay/UpdateNotice")
	notice.config = notice.config.duplicate()
	notice.config.enabled = false
	root.add_child(world)
	guardian = world.get_node("AshenShrine/Guardian")
	player = world.get_node("Player")
	vitals = player.get_node("Vitals")
	quest = world.get_node("QuestManager")
	quest.report_event("speak_to_mira")
	quest.report_event("inspect_survey_marker")
	player.global_position = guardian.global_position + Vector3(1.5, 0.1, 0)
	player.camera_pivot.rotation.y = 0.0
	player.set_touch_move(Vector2(1, 0))
	for i in range(100): await physics_frame
	player.set_touch_move(Vector2.ZERO)
	check(player.global_position.x - guardian.global_position.x > guardian.attack_range and vitals.health == 100, "Moving out during a real wind-up avoids the strike")
	check(not guardian.attack_warning.visible, "Warning clears after the real physics strike")
	world.free()
	quit(1 if failed else 0)
