extends Node
## Offline prototype only. Future multiplayer must validate damage on the server.
signal health_changed(current: int, maximum: int)
signal respawned

@export var max_health := 100
@export var spawn_position := Vector3(0, 0.1, 18)
@onready var player: CharacterBody3D = get_parent() as CharacterBody3D
var health: int

func _ready() -> void:
	health = max_health
	health_changed.emit(health, max_health)

func take_damage(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return
	health = maxi(0, health - amount)
	health_changed.emit(health, max_health)
	if health == 0:
		player.global_position = spawn_position
		player.velocity = Vector3.ZERO
		health = max_health
		health_changed.emit(health, max_health)
		respawned.emit()
