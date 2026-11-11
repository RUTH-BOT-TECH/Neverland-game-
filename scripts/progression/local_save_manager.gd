extends Node
## Offline prototype checkpoints only. Never use this file as evidence of multiplayer
## rewards, account ownership, or a Champion result; the server must validate those.

@export var enabled := true
@export var save_path := "user://eldoria_local_progress_v1.json"
@export var quest_manager_path: NodePath
@export var inventory_path: NodePath
@export var guardian_path: NodePath
@export var orb_path: NodePath
@export var warning_label_path: NodePath

const SAVE_VERSION := 1
const MAX_BYTES := 16384

@onready var quest_manager = get_node(quest_manager_path)
@onready var inventory = get_node(inventory_path)
@onready var guardian = get_node(guardian_path)
@onready var orb = get_node(orb_path)
@onready var warning_label: Label = get_node(warning_label_path)

var writes_blocked := false
var primary_valid := false
var last_error := ""

func _ready() -> void:
	if not enabled:
		return
	_load_progress()
	quest_manager.quest_changed.connect(_on_progress_changed)
	guardian.guardian_defeated.connect(_on_progress_changed)
	inventory.orb_added.connect(_on_orb_added)

func _on_progress_changed() -> void:
	save_now()

func _on_orb_added(_orb_id: StringName) -> void:
	save_now()

func _warn(message: String, block_writes := false) -> void:
	last_error = message
	if block_writes:
		writes_blocked = true
	warning_label.text = message
	warning_label.show()
	push_warning("LocalSaveManager: " + message)

func _read_candidate(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"state": "missing"}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > MAX_BYTES:
		return {"state": "invalid"}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return {"state": "invalid"}
	var data: Variant = parser.data
	if not data is Dictionary:
		return {"state": "invalid"}
	var ver: Variant = data.get("version")
	if not _whole_number(ver):
		return {"state": "invalid"}
	if int(ver) > SAVE_VERSION:
		return {"state": "future"}
	if int(ver) != SAVE_VERSION or data.get("quest_id") != "heralds_warning":
		return {"state": "invalid"}
	var index: Variant = data.get("objective_index")
	var defeated: Variant = data.get("guardian_defeated")
	var owned: Variant = data.get("owned_orbs")
	if not _whole_number(index) or int(index) < 0 or int(index) > quest_manager.quest.objective_event_ids.size():
		return {"state": "invalid"}
	if not defeated is bool or not owned is Array or owned.size() > 1:
		return {"state": "invalid"}
	if not owned.is_empty() and owned[0] != "orb_flame":
		return {"state": "invalid"}
	var complete: bool = int(index) == quest_manager.quest.objective_event_ids.size()
	if (defeated and not complete) or (not owned.is_empty() and not defeated):
		return {"state": "invalid"}
	return {"state": "valid", "data": data}

func _whole_number(value: Variant) -> bool:
	if not (value is int or value is float):
		return false
	return is_finite(float(value)) and float(value) == floorf(float(value)) and absf(float(value)) < 1000000.0

func _load_progress() -> void:
	var primary := _read_candidate(save_path)
	if primary.state == "future":
		_warn("This save is from a newer version. Local saving is paused to protect it.", true)
		return
	if primary.state == "valid":
		primary_valid = true
		_apply(primary.data)
		return
	var backup := _read_candidate(save_path + ".bak")
	if backup.state == "future":
		_warn("The backup is from a newer version. Local saving is paused to protect it.", true)
		return
	if backup.state == "valid":
		_apply(backup.data)
		_warn("Recovered the previous local checkpoint. Recent progress may be missing.")
		return
	if primary.state != "missing" or backup.state != "missing":
		_warn("Local save could not be read. Saving is paused to protect your files.", true)

func _apply(data: Dictionary) -> void:
	quest_manager.objective_index = int(data.objective_index)
	if quest_manager.objective_index == quest_manager.quest.objective_event_ids.size():
		quest_manager.status = quest_manager.QuestStatus.COMPLETED
		quest_manager.session_xp = quest_manager.quest.reward_xp
	else:
		quest_manager.status = quest_manager.QuestStatus.ACTIVE
		quest_manager.session_xp = 0
	if data.guardian_defeated:
		guardian.restore_defeated()
	if not data.owned_orbs.is_empty():
		orb.restore_collected()
		inventory.add_unique_orb(&"orb_flame")
	# Refreshes UI without re-awarding the quest reward or firing completion.
	quest_manager.quest_changed.emit()

func save_now() -> bool:
	if not enabled or writes_blocked:
		return false
	var owned: Array[String] = []
	if inventory.has_orb(&"orb_flame"):
		owned.append("orb_flame")
	var data := {
		"version": SAVE_VERSION,
		"quest_id": "heralds_warning",
		"objective_index": quest_manager.objective_index,
		"guardian_defeated": guardian.defeated,
		"owned_orbs": owned,
	}
	var tmp := save_path + ".tmp"
	var file := FileAccess.open(tmp, FileAccess.WRITE)
	if file == null:
		_warn("Could not save local progress. Check device storage.", true)
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		_warn("Could not save local progress. Check device storage.", true)
		return false
	var main_abs := ProjectSettings.globalize_path(save_path)
	var backup_abs := ProjectSettings.globalize_path(save_path + ".bak")
	if FileAccess.file_exists(save_path):
		if primary_valid:
			if FileAccess.file_exists(save_path + ".bak") and DirAccess.remove_absolute(backup_abs) != OK:
				_warn("Could not update local backup. Saving is paused.", true)
				return false
			if DirAccess.rename_absolute(main_abs, backup_abs) != OK:
				_warn("Could not back up local progress. Saving is paused.", true)
				return false
		else:
			# Preserve an unreadable primary before replacing it after recovery.
			var damaged := save_path + ".damaged"
			if FileAccess.file_exists(damaged) or DirAccess.rename_absolute(main_abs, ProjectSettings.globalize_path(damaged)) != OK:
				_warn("Could not protect the damaged save. Saving is paused.", true)
				return false
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), main_abs) != OK:
		_warn("Could not finish saving. The previous checkpoint was kept.", true)
		return false
	primary_valid = true
	return true
