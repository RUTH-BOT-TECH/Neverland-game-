extends Node3D
## Local village NPC. Patrol and dialogue are prototypes, not network-authoritative.
@export var dialogue: Resource
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
