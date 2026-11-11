extends Node
## Local, session-only quest prototype. Not authoritative and not saved.
## Later multiplayer implementation must validate and persist events on the server.
signal quest_changed
signal quest_completed(quest_id: StringName, xp_granted: int)

enum QuestStatus { UNAVAILABLE, ACTIVE, COMPLETED }

@export var quest: Resource
var status: QuestStatus = QuestStatus.UNAVAILABLE
var objective_index := 0
var session_xp := 0

func _ready() -> void:
	if quest == null:
		push_error("QuestManager: quest definition is missing.")
		return
	if quest.quest_id == &"" or quest.objective_event_ids.is_empty() or quest.objective_event_ids.size() != quest.objective_texts.size() or quest.reward_xp < 0:
		push_error("QuestManager: quest definition is invalid.")
		return
	status = QuestStatus.ACTIVE
	quest_changed.emit()

func is_expecting(event_id: String) -> bool:
	return status == QuestStatus.ACTIVE and objective_index < quest.objective_event_ids.size() and quest.objective_event_ids[objective_index] == event_id

func report_event(event_id: String) -> bool:
	if not is_expecting(event_id):
		return false
	objective_index += 1
	if objective_index == quest.objective_event_ids.size():
		status = QuestStatus.COMPLETED
		session_xp += quest.reward_xp
		quest_changed.emit()
		quest_completed.emit(quest.quest_id, quest.reward_xp)
	else:
		quest_changed.emit()
	return true

func on_herald_dialogue_finished() -> void:
	report_event("speak_to_mira")
