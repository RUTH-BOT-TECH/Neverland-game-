extends Node3D
## Local collection prototype; server validation is required for multiplayer.
signal collected(orb_id: StringName)
@export var definition: Resource
@export var player_path: NodePath
@export var guardian_path: NodePath
@export var inventory_path: NodePath
@export var collect_range := 3.0
@onready var player = get_node(player_path)
@onready var guardian = get_node(guardian_path)
@onready var inventory = get_node(inventory_path)
@onready var visual: Node3D = $Visual
var is_collected := false
var elapsed := 0.0

func _process(delta: float) -> void:
	if is_collected:
		return
	elapsed += delta
	visual.position.y = sin(elapsed * 2.0) * 0.12
	visual.rotation.y += delta * 0.7

func can_collect() -> bool:
	if is_collected or not guardian.defeated or not player.controls_enabled:
		return false
	var diff: Vector3 = player.global_position - global_position
	return absf(diff.y) <= 3.0 and Vector2(diff.x, diff.z).length() <= collect_range

func try_collect() -> bool:
	if not can_collect() or definition == null:
		return false
	if not inventory.add_unique_orb(definition.orb_id):
		return false
	is_collected = true
	var tween := create_tween()
	tween.tween_property(visual, "scale", Vector3.ZERO, 0.35)
	tween.tween_callback(visual.hide)
	collected.emit(definition.orb_id)
	return true
