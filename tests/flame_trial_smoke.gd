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
	var world := (load("res://scenes/world/Foundation.tscn") as PackedScene).instantiate()
	var config = world.get_node("Overlay/UpdateNotice").config.duplicate()
	config.enabled = false
	world.get_node("Overlay/UpdateNotice").config = config
	root.add_child(world)
	var player = world.get_node("Player")
	var vitals = player.get_node("Vitals")
	var combat = player.get_node("Combat")
	var guardian = world.get_node("AshenShrine/Guardian")
	var orb = world.get_node("AshenShrine/FlameOrb")
	var inventory = world.get_node("OrbInventory")
	var manager = world.get_node("QuestManager")
	var ui = world.get_node("Overlay/FlameTrialUI")
	var controls = world.get_node("Overlay/TouchControls")
	await process_frame
	check(vitals.health == 100 and inventory.orb_count() == 0, "Starting health and empty inventory")
	guardian.take_damage(20)
	check(guardian.health == 100 and not orb.try_collect(), "Trial locked until introductory quest is complete")
	check(manager.report_event("speak_to_mira") and manager.report_event("inspect_survey_marker"), "Introductory quest can unlock trial")
	player.global_position = guardian.global_position + Vector3(0, 0, 2.0)
	player.visual.rotation.y = PI
	combat.cooldown_left = 0.0
	combat.try_attack()
	check(guardian.health == 100, "Attacks do not hit enemies behind the player")
	player.visual.rotation.y = 0.0
	combat.cooldown_left = 0.0
	var touch := InputEventScreenTouch.new()
	touch.index = 8
	touch.pressed = true
	touch.position = controls.get_global_transform_with_canvas() * controls._attack_center()
	controls._input(touch)
	check(guardian.health == 80 and player.attack_animation_left > 0, "Attack touch damages guardian and starts animation")
	check(not combat.try_attack() and guardian.health == 80, "Attack cooldown prevents rapid hits")
	touch.pressed = false
	controls._input(touch)
	guardian.windup_left = 0.01
	guardian._physics_process(0.02)
	check(vitals.health == 85, "Guardian's telegraphed hit damages the player")
	vitals.take_damage(999)
	check(vitals.health == 100 and player.global_position.distance_to(vitals.spawn_position) < 0.01 and guardian.health == guardian.max_health, "Defeat respawns player and resets undefeated guardian")
	player.global_position = guardian.global_position + Vector3(0, 0, 2.0)
	player.visual.rotation.y = 0.0
	for i in range(5):
		combat.cooldown_left = 0.0
		combat.try_attack()
	check(guardian.defeated and guardian.health == 0, "Five hits defeat the guardian")
	check(not orb.try_collect(), "Orb cannot be collected from too far away")
	player.global_position = orb.global_position + Vector3(1.0, -1.75, 0)
	await process_frame
	await process_frame
	check(ui.collect_button.visible, "Collect button appears after guardian defeat")
	var interact := InputEventAction.new()
	interact.action = "interact"
	interact.pressed = true
	root.push_input(interact, true)
	await process_frame
	check(inventory.has_orb(&"orb_flame") and inventory.orb_count() == 1 and orb.is_collected, "Interaction collects unique Flame Orb")
	check(not inventory.add_unique_orb(&"orb_flame") and not orb.try_collect() and inventory.orb_count() == 1, "Duplicate Orb collection is prevented")
	check(not inventory.add_unique_orb(&"unknown_orb"), "Unknown Orb identifiers are rejected")
	check(ui.info.text.contains("1/5"), "HUD reflects collection count")
	world.queue_free()
	quit(1 if failed else 0)
