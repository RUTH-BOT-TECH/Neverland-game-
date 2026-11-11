extends Node
## Minimal local melee prototype. Not a full or authoritative combat system.
@export var damage := 20
@export var attack_range := 2.8
@export var cooldown_seconds := 0.75
@export var facing_threshold := 0.25
@onready var player = get_parent()
var cooldown_left := 0.0

func _physics_process(delta: float) -> void:
	cooldown_left = maxf(0.0, cooldown_left - delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") and not event.is_echo() and player.controls_enabled:
		try_attack()
		get_viewport().set_input_as_handled()

func try_attack() -> bool:
	if not player.controls_enabled or cooldown_left > 0.0:
		return false
	cooldown_left = cooldown_seconds
	player.play_attack_animation()
	var forward: Vector3 = -player.visual.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var best: Node3D = null
	var best_distance := attack_range
	for candidate in get_tree().get_nodes_in_group("local_guardians"):
		if not is_instance_valid(candidate) or candidate.defeated:
			continue
		var difference: Vector3 = candidate.global_position - player.global_position
		if absf(difference.y) > 2.0:
			continue
		difference.y = 0.0
		var distance := difference.length()
		if distance > 0.01 and distance <= best_distance and forward.dot(difference / distance) >= facing_threshold:
			best = candidate
			best_distance = distance
	if best != null:
		best.take_damage(damage)
	return true
