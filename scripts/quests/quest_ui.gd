extends Control
## Displays a local prototype quest and allows nearby marker interaction.
@export var player_path: NodePath
@export var quest_manager_path: NodePath
@export var survey_marker_path: NodePath
@export_range(1.0, 10.0, 0.1) var interaction_distance := 3.0

@onready var player = get_node(player_path)
@onready var quest_manager = get_node(quest_manager_path)
@onready var survey_marker: Node3D = get_node(survey_marker_path) as Node3D
@onready var title: Label = $Tracker/Margin/Content/Title
@onready var objective: Label = $Tracker/Margin/Content/Objective
@onready var examine_button: Button = $ExamineButton

func _ready() -> void:
	examine_button.hide()
	quest_manager.quest_changed.connect(_refresh_tracker)
	_refresh_tracker()

func _refresh_tracker() -> void:
	if quest_manager.quest == null:
		title.text = "Quest unavailable"
		objective.text = ""
		return
	title.text = quest_manager.quest.title
	if quest_manager.status == quest_manager.QuestStatus.COMPLETED:
		objective.text = "Completed  •  +%d XP (session only)" % quest_manager.quest.reward_xp
	elif quest_manager.status == quest_manager.QuestStatus.ACTIVE:
		objective.text = quest_manager.quest.objective_texts[quest_manager.objective_index]
	else:
		objective.text = "Quest unavailable"

func _process(_delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(survey_marker) or not is_instance_valid(quest_manager):
		examine_button.hide()
		return
	var difference: Vector3 = player.global_position - survey_marker.global_position
	var in_range := Vector2(difference.x, difference.z).length() <= interaction_distance
	examine_button.visible = player.controls_enabled and in_range and quest_manager.is_expecting("inspect_survey_marker")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo() and examine_button.visible:
		examine_marker()
		get_viewport().set_input_as_handled()

func examine_marker() -> void:
	# Re-check range and phase at the moment of interaction rather than trusting
	# visibility from a previous frame. Server-side checks will be needed later.
	if not is_instance_valid(player) or not is_instance_valid(survey_marker) or not is_instance_valid(quest_manager):
		return
	var difference: Vector3 = player.global_position - survey_marker.global_position
	if not player.controls_enabled or Vector2(difference.x, difference.z).length() > interaction_distance:
		return
	if quest_manager.report_event("inspect_survey_marker"):
		examine_button.hide()
