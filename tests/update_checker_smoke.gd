extends SceneTree

var failed := false
var signal_count := 0

func _initialize() -> void:
	call_deferred("run_test")

func check(value: bool, message: String) -> void:
	if value:
		print("PASS: ", message)
	else:
		failed = true
		push_error("FAIL: " + message)

func make_release(tag: String, url: String, draft: bool = false, apk: bool = true) -> Dictionary:
	return {"tag_name": tag, "html_url": url, "draft": draft, "assets": [{"name": "Five_Missing_Orbs_Test.apk"}] if apk else []}

func run_test() -> void:
	var world := (load("res://scenes/world/Foundation.tscn") as PackedScene).instantiate()
	# Keep tests independent of network and repository state.
	var test_update_config = world.get_node("Overlay/UpdateNotice").config.duplicate()
	test_update_config.enabled = false
	world.get_node("Overlay/UpdateNotice").config = test_update_config
	world.get_node("LocalSaveManager").enabled = false # Isolate gameplay tests from real local saves.
	root.add_child(world)
	var checker = world.get_node("Overlay/UpdateNotice")
	await process_frame
	check(not checker.config.enabled and not checker.panel.visible and not checker._checking, "Update checks can be disabled without making a network request")
	checker.config = checker.config.duplicate()
	checker.config.github_owner = "eldoria-team"
	checker.config.github_repository = "five-orbs"
	checker.config.current_build_number = 2
	var base := "https://github.com/eldoria-team/five-orbs/releases/tag/"
	var data := [make_release("preview-1", base + "preview-1"), make_release("preview-3", base + "preview-3"), make_release("preview-8", base + "preview-8", true), make_release("preview-4", base + "preview-4")]
	var chosen: Dictionary = checker.select_release(JSON.stringify(data))
	check(chosen.get("build_number", 0) == 4 and chosen.get("release_url", "") == base + "preview-4", "Selects highest newer published preview")
	check(checker.select_release("not-json").is_empty(), "Malformed JSON ignored")
	check(checker.select_release(JSON.stringify([make_release("preview-2", base + "preview-2")])).is_empty(), "Current build does not trigger update")
	check(checker.select_release(JSON.stringify([make_release("preview-10", "https://evil.example/phish")])).is_empty(), "External host rejected")
	check(checker.select_release(JSON.stringify([make_release("preview-99", base + "preview-3")])).is_empty(), "Mismatched release tag URL rejected")
	check(checker.select_release(JSON.stringify([make_release("preview-5", base + "preview-5", false, false)])).is_empty(), "Release without expected APK ignored")
	check(checker.select_release(JSON.stringify([make_release("preview-+3", base + "preview-+3")])).is_empty(), "Non-numeric tag rejected")
	checker.update_available.connect(func(_number: int, _url: String) -> void: signal_count += 1)
	checker._on_request_completed(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), JSON.stringify(data).to_utf8_buffer())
	check(checker.panel.visible and checker.latest_release_url == base + "preview-4" and signal_count == 1, "Successful response displays update notice")
	checker.dismiss()
	checker._on_request_completed(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())
	check(not checker.panel.visible, "Offline check leaves notice hidden")
	checker.config.github_owner = "attacker.example/path"
	check(checker.select_release(JSON.stringify(data)).is_empty(), "Unsafe repository name rejected")
	world.queue_free()
	quit(1 if failed else 0)
