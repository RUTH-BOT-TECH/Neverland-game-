extends Control
## Checks a public GitHub Releases feed when enabled. It never installs an APK.
## Android's installer and signing checks remain responsible for installation.
signal update_available(build_number: int, release_url: String)

@export var config: Resource
@onready var request: HTTPRequest = $Request
@onready var panel: PanelContainer = $Panel
@onready var text: Label = $Panel/Margin/Content/Text

var latest_release_url := ""
var _checking := false

func _ready() -> void:
	panel.hide()
	request.request_completed.connect(_on_request_completed)
	if config != null and config.enabled:
		check_for_updates()

func _valid_component(value: String) -> bool:
	if value.is_empty() or value == "." or value == ".." or value.length() > 100:
		return false
	for i in range(value.length()):
		var code := value.unicode_at(i)
		if not ((code >= 48 and code <= 57) or (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or code == 45 or code == 46 or code == 95):
			return false
	return true

func check_for_updates() -> void:
	if _checking or config == null or not config.enabled:
		return
	if not _valid_component(config.github_owner) or not _valid_component(config.github_repository):
		push_warning("Update check disabled: invalid repository configuration.")
		return
	var api_url: String = "https://api.github.com/repos/%s/%s/releases?per_page=20" % [config.github_owner, config.github_repository]
	_checking = true
	var err := request.request(api_url, PackedStringArray(["Accept: application/vnd.github+json", "User-Agent: FiveMissingOrbs-Preview"]))
	if err != OK:
		_checking = false
		push_warning("Unable to start update check (%d)." % err)

func select_release(json_text: String) -> Dictionary:
	## Only preview-N releases from the configured repository are accepted.
	## Separated from network IO for deterministic tests.
	if config == null or not _valid_component(config.github_owner) or not _valid_component(config.github_repository):
		return {}
	var parser := JSON.new()
	if parser.parse(json_text) != OK:
		return {}
	var parsed: Variant = parser.data
	if typeof(parsed) != TYPE_ARRAY:
		return {}
	var safe_prefix: String = ("https://github.com/%s/%s/releases/tag/" % [config.github_owner, config.github_repository]).to_lower()
	var best_build: int = config.current_build_number
	var best_url := ""
	for release: Variant in parsed:
		if typeof(release) != TYPE_DICTIONARY or release.get("draft", true) != false:
			continue
		var tag: Variant = release.get("tag_name", null)
		var url: Variant = release.get("html_url", null)
		if typeof(tag) != TYPE_STRING or typeof(url) != TYPE_STRING:
			continue
		if not tag.begins_with("preview-") or not url.to_lower().begins_with(safe_prefix):
			continue
		var suffix: String = tag.trim_prefix("preview-")
		if suffix.is_empty() or suffix.length() > 9 or not suffix.is_valid_int():
			continue
		# is_valid_int() also accepts signs; require digits only.
		var digits_only := true
		for c in suffix:
			if c < "0" or c > "9":
				digits_only = false
				break
		if not digits_only:
			continue
		var assets: Variant = release.get("assets", null)
		if typeof(assets) != TYPE_ARRAY:
			continue
		var has_preview_apk := false
		for asset: Variant in assets:
			if typeof(asset) == TYPE_DICTIONARY and asset.get("name", "") == "Five_Missing_Orbs_Test.apk":
				has_preview_apk = true
				break
		if not has_preview_apk:
			continue
		# Verify the release URL is the page for this exact version tag.
		if url.to_lower() != safe_prefix + tag.to_lower():
			continue
		var candidate := suffix.to_int()
		if candidate > best_build:
			best_build = candidate
			best_url = url
	if best_url.is_empty():
		return {}
	return {"build_number": best_build, "release_url": best_url}

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_checking = false
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		# Offline and rate-limited clients can continue playing normally.
		return
	var release := select_release(body.get_string_from_utf8())
	if release.is_empty():
		return
	latest_release_url = release.release_url
	text.text = "Preview update %d is available." % release.build_number
	panel.show()
	update_available.emit(release.build_number, latest_release_url)

func open_release_page() -> void:
	if not latest_release_url.is_empty():
		OS.shell_open(latest_release_url)

func dismiss() -> void:
	panel.hide()
