extends SceneTree
## Run twice in separate processes with -- write and -- read, in that order.
const PATH := "user://eldoria_restart_smoke_only.json"

func _initialize() -> void:
	call_deferred("run_test")

func clean() -> void:
	for suffix in ["", ".bak", ".tmp", ".damaged"]:
		if FileAccess.file_exists(PATH + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH + suffix))

func run_test() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1 or args[0] not in ["write", "read"]:
		push_error("Use -- write or -- read")
		quit(2)
		return
	if args[0] == "write":
		clean()
	var world := (load("res://scenes/world/Foundation.tscn") as PackedScene).instantiate()
	world.get_node("LocalSaveManager").save_path = PATH
	var notice = world.get_node("Overlay/UpdateNotice")
	notice.config = notice.config.duplicate()
	notice.config.enabled = false
	root.add_child(world)
	var quest = world.get_node("QuestManager")
	var guardian = world.get_node("AshenShrine/Guardian")
	var orb = world.get_node("AshenShrine/FlameOrb")
	var inventory = world.get_node("OrbInventory")
	var ok := false
	if args[0] == "write":
		quest.report_event("speak_to_mira")
		quest.report_event("inspect_survey_marker")
		guardian.take_damage(100)
		world.get_node("Player").global_position = orb.global_position + Vector3(1, -1.75, 0)
		ok = orb.try_collect() and FileAccess.file_exists(PATH) and not world.get_node("LocalSaveManager").writes_blocked
	else:
		ok = quest.objective_index == 2 and quest.session_xp == 25 and guardian.defeated and orb.is_collected and inventory.has_orb(&"orb_flame")
		clean()
	print("Restart smoke ", args[0], ": ", "PASS" if ok else "FAIL")
	world.free()
	quit(0 if ok else 1)
