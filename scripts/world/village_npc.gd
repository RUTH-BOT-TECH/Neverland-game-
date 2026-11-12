extends Node3D
## Local village NPC. Patrol and dialogue are prototypes, not network-authoritative.
@export var dialogue: Resource
@export var survey_dialogue: Resource
@export var trial_dialogue: Resource
@export var guardian_defeated_dialogue: Resource
@export var flame_recovered_dialogue: Resource
@export var quest_manager_path: NodePath
@export var guardian_path: NodePath
@export var inventory_path: NodePath
@export_range(0.0, 3.0, 0.1) var patrol_radius: float = 0.8

@onready var label: Label3D = $NameLabel
@onready var model: Node3D = $Model
@onready var animation_player: AnimationPlayer = $Model/Peasant/AnimationPlayer

var _origin: Vector3
var _patrol_time := 0.0
var _talking := false
var _walking := false

func _ready() -> void:
	_origin = position
	if dialogue != null:
		label.text = dialogue.speaker_name
	for clip in ["Idle", "Walk"]:
		if animation_player.has_animation(clip):
			animation_player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	_set_animation("Idle")

func current_dialogue() -> Resource:
	# Conversation is chosen from current local progress, never authoritative.
	# Missing dependencies/resources gracefully fall back to the opening dialogue.
	var inventory = get_node_or_null(inventory_path) if not inventory_path.is_empty() else null
	var guardian = get_node_or_null(guardian_path) if not guardian_path.is_empty() else null
	var quest = get_node_or_null(quest_manager_path) if not quest_manager_path.is_empty() else null
	if inventory != null and inventory.has_orb(&"orb_flame") and flame_recovered_dialogue != null:
		return flame_recovered_dialogue
	if guardian != null and guardian.defeated and guardian_defeated_dialogue != null:
		return guardian_defeated_dialogue
	if quest != null and quest.status == quest.QuestStatus.COMPLETED and trial_dialogue != null:
		return trial_dialogue
	if quest != null and quest.is_expecting("inspect_survey_marker") and survey_dialogue != null:
		return survey_dialogue
	return dialogue

func set_talking(value: bool) -> void:
	_talking = value
	if value:
		_walking = false
		_set_animation("Idle")

func _set_animation(clip: String) -> void:
	if animation_player.has_animation(clip) and (animation_player.current_animation != clip or not animation_player.is_playing()):
		animation_player.play(clip, 0.2)

func _process(delta: float) -> void:
	if _talking or patrol_radius <= 0.0:
		return
	# Pause at each end, then walk to the opposite end along the local x axis.
	# The patrol is visual-only and deliberately stays on the open village verge.
	_patrol_time += delta
	var phase := fmod(_patrol_time, 8.0)
	var next_x := position.x
	_walking = false
	if phase >= 1.0 and phase < 3.0:
		next_x = _origin.x + patrol_radius * (phase - 1.0) / 2.0
		_walking = true
		model.rotation.y = PI / 2.0
	elif phase >= 4.0 and phase < 6.0:
		next_x = _origin.x + patrol_radius * (1.0 - (phase - 4.0) / 2.0)
		_walking = true
		model.rotation.y = -PI / 2.0
	position.x = next_x
	_set_animation("Walk" if _walking else "Idle")
