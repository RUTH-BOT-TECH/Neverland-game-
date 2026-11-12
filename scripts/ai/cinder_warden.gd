extends Node3D
## Stationary starter guardian with a short attack wind-up. Local prototype only.
signal health_changed(current: int, maximum: int)
signal guardian_defeated

@export var player_path: NodePath
@export var quest_manager_path: NodePath
@export var max_health := 100
@export var attack_damage := 15
@export var attack_range := 2.3
@export_range(0.1, 5.0, 0.05) var windup_seconds := 1.1
@export var cooldown_seconds := 1.3

@onready var player = get_node(player_path)
@onready var quest_manager = get_node(quest_manager_path)
@onready var animation: AnimationPlayer = $Model/Juggernaut/AnimationPlayer
@onready var name_label: Label3D = $NameLabel
@onready var attack_warning: Node3D = $AttackWarning
var health: int
var defeated := false
var windup_left := 0.0
var cooldown_left := 0.0

func _ready() -> void:
	add_to_group("local_guardians")
	health = max_health
	_set_warning(false)
	if animation.has_animation("Idle"):
		animation.get_animation("Idle").loop_mode = Animation.LOOP_LINEAR
		animation.play("Idle")
	player.get_node("Vitals").respawned.connect(_on_player_respawned)
	_update_label()

func _unlocked() -> bool:
	return quest_manager.status == quest_manager.QuestStatus.COMPLETED

func take_damage(amount: int) -> void:
	if not _unlocked() or defeated or amount <= 0:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	if health == 0:
		_set_defeated_visuals()
		guardian_defeated.emit()
	else:
		_update_label()

func _set_defeated_visuals() -> void:
	defeated = true
	health = 0
	windup_left = 0.0
	cooldown_left = 0.0
	_set_warning(false)
	name_label.text = "Cinder Warden defeated"
	if animation.has_animation("Death"):
		animation.play("Death")

func restore_defeated() -> void:
	# Restore presentation without emitting a new reward/defeat event.
	_set_defeated_visuals()

func _set_warning(active: bool) -> void:
	# The ring's outer edge is the same horizontal radius used by _player_in_range.
	# The filled disk remains full-sized throughout the wind-up: it is a danger
	# area, not an indication of a shrinking hit radius.
	attack_warning.visible = active
	attack_warning.scale = Vector3(maxf(attack_range, 0.0), 1.0, maxf(attack_range, 0.0))

func _update_label() -> void:
	if windup_left > 0.0:
		name_label.text = "Cinder Warden  •  MOVE AWAY!"
	else:
		name_label.text = "Cinder Warden  %d/%d" % [health, max_health]

func _player_in_range() -> bool:
	var diff: Vector3 = player.global_position - global_position
	return absf(diff.y) <= 2.0 and Vector2(diff.x, diff.z).length() <= attack_range

func _physics_process(delta: float) -> void:
	if defeated or not _unlocked() or not player.controls_enabled:
		return
	if windup_left > 0.0:
		windup_left -= delta
		if windup_left <= 0.0:
			_set_warning(false)
			if _player_in_range():
				player.get_node("Vitals").take_damage(attack_damage)
			cooldown_left = cooldown_seconds
			_update_label()
		return
	cooldown_left = maxf(0.0, cooldown_left - delta)
	if cooldown_left == 0.0 and _player_in_range():
		windup_left = windup_seconds
		_set_warning(true)
		_update_label()
		if animation.has_animation("Attack"):
			animation.play("Attack")
	elif windup_left <= 0.0 and not animation.is_playing() and animation.has_animation("Idle"):
		animation.play("Idle")

func _on_player_respawned() -> void:
	if defeated:
		return
	health = max_health
	windup_left = 0.0
	cooldown_left = 0.0
	_set_warning(false)
	_update_label()
	health_changed.emit(health, max_health)
