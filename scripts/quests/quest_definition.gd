extends Resource
## Declarative quest content. Objective IDs are matched in sequence.
@export var quest_id: StringName
@export var title: String
@export_multiline var description: String
@export var objective_event_ids: PackedStringArray
@export var objective_texts: PackedStringArray
@export var reward_xp: int = 0
