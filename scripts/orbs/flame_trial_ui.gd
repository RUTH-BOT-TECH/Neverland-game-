extends Control
## Session-only encounter UI; inventory is not persistent or multiplayer-safe.
@export var player_path: NodePath
@export var guardian_path: NodePath
@export var quest_manager_path: NodePath
@export var orb_path: NodePath
@export var inventory_path: NodePath

@onready var player = get_node(player_path)
@onready var guardian = get_node(guardian_path)
@onready var quest_manager = get_node(quest_manager_path)
@onready var orb = get_node(orb_path)
@onready var inventory = get_node(inventory_path)
@onready var health_bar: ProgressBar = $Status/Margin/Content/Health
@onready var health_label: Label = $Status/Margin/Content/HealthText
@onready var info: Label = $Status/Margin/Content/Info
@onready var collect_button: Button = $CollectButton

func _ready() -> void:
	player.get_node("Vitals").health_changed.connect(_on_health_changed)
	guardian.guardian_defeated.connect(_refresh)
	inventory.orb_added.connect(_on_orb_added)
	quest_manager.quest_changed.connect(_refresh)
	_on_health_changed(player.get_node("Vitals").health, player.get_node("Vitals").max_health)
	_refresh()

func _on_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "Health  %d/%d" % [current, maximum]

func _on_orb_added(_orb_id: StringName) -> void:
	_refresh()

func _refresh() -> void:
	if inventory.has_orb(&"orb_flame"):
		info.text = "Orb of Flame recovered  •  Orbs %d/5" % inventory.orb_count()
	elif quest_manager.status != quest_manager.QuestStatus.COMPLETED:
		info.text = "Orbs %d/5  •  Finish Mira's quest to unlock the Flame trial" % inventory.orb_count()
	elif not guardian.defeated:
		info.text = "Flame trial: defeat the Cinder Warden east of the ruins"
	else:
		info.text = "Flame trial: collect the Orb of Flame"

func _process(_delta: float) -> void:
	collect_button.visible = orb.can_collect()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo() and collect_button.visible:
		collect_orb()
		get_viewport().set_input_as_handled()

func collect_orb() -> void:
	if orb.try_collect():
		collect_button.hide()
