extends CharacterBody3D
## Local prototype controller. This is not yet network-authoritative.

@export var move_speed: float = 5.0
@export var acceleration: float = 18.0
@export var jump_velocity: float = 5.0
@export var touch_look_sensitivity: float = 0.006
@export var keyboard_look_speed: float = 1.8

@onready var visual: Node3D = $Visual
@onready var camera_pivot: Node3D = $CameraPivot

var touch_move := Vector2.ZERO
var jump_queued := false
var controls_enabled := true
var attack_animation_left := 0.0
@onready var character_animation: AnimationPlayer = $Visual/KnightModel/AnimationPlayer
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	$CameraPivot/SpringArm3D.add_excluded_object(get_rid())
	for clip in ["Idle", "Walk", "Run"]:
		if character_animation.has_animation(clip):
			character_animation.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
	character_animation.play("Idle")

func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	if not enabled:
		touch_move = Vector2.ZERO
		jump_queued = false
		velocity.x = 0.0
		velocity.z = 0.0

func set_touch_move(value: Vector2) -> void:
	if controls_enabled:
		touch_move = value.limit_length(1.0)

func queue_jump() -> void:
	if controls_enabled:
		jump_queued = true

func look_by(delta: Vector2) -> void:
	if not controls_enabled:
		return
	camera_pivot.rotation.y -= delta.x * touch_look_sensitivity
	camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - delta.y * touch_look_sensitivity, deg_to_rad(-65.0), deg_to_rad(15.0))

func play_attack_animation() -> void:
	if controls_enabled:
		attack_animation_left = 0.74

func _physics_process(delta: float) -> void:
	if global_position.y < -10.0:
		global_position = Vector3(0, 0.1, 18)
		velocity = Vector3.ZERO
	var look_input := Input.get_vector("look_left", "look_right", "look_up", "look_down") if controls_enabled else Vector2.ZERO
	camera_pivot.rotation.y -= look_input.x * keyboard_look_speed * delta
	camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - look_input.y * keyboard_look_speed * delta, deg_to_rad(-65.0), deg_to_rad(15.0))

	var input_vector := (Input.get_vector("move_left", "move_right", "move_forward", "move_back") + touch_move).limit_length(1.0) if controls_enabled else Vector2.ZERO
	var forward := -camera_pivot.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := camera_pivot.global_basis.x
	right.y = 0.0
	right = right.normalized()
	var direction := right * input_vector.x - forward * input_vector.y
	var target_velocity := direction * move_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif controls_enabled and (jump_queued or Input.is_action_just_pressed("jump")):
		velocity.y = jump_velocity
	jump_queued = false
	if direction.length_squared() > 0.01:
		var target_angle := atan2(-direction.x, -direction.z)
		visual.rotation.y = lerp_angle(visual.rotation.y, target_angle, minf(1.0, 12.0 * delta))
	move_and_slide()
	# Separate animation clips supplied with the CC0 character model.
	attack_animation_left = maxf(0.0, attack_animation_left - delta)
	var animation_name := "Run" if is_on_floor() and Vector2(velocity.x, velocity.z).length() > 0.3 else "Idle"
	if attack_animation_left > 0.0 and controls_enabled:
		animation_name = "Sword slash"
	# Fit the one-second sword clip within the existing 0.75s combat cooldown.
	character_animation.speed_scale = 1.35 if animation_name == "Sword slash" else 1.0
	if character_animation.current_animation != animation_name or not character_animation.is_playing():
		character_animation.play(animation_name, 0.15)
