extends Control
## Local dialogue presentation. Quest state and multiplayer are not handled here.
signal dialogue_finished
@export var player_path: NodePath
@export var npc_path: NodePath
@export_range(1.0, 10.0, 0.1) var interaction_distance := 3.0

@onready var player: CharacterBody3D = get_node(player_path) as CharacterBody3D
@onready var npc: Node3D = get_node(npc_path) as Node3D
@onready var talk_button: Button = $TalkButton
@onready var panel: PanelContainer = $DialoguePanel
@onready var speaker: Label = $DialoguePanel/Margin/Contents/Speaker
@onready var line_label: Label = $DialoguePanel/Margin/Contents/Line
@onready var next_button: Button = $DialoguePanel/Margin/Contents/Buttons/NextButton

var _current_line := 0
var _in_dialogue := false

func _ready() -> void:
	panel.hide()
	talk_button.hide()

func _process(_delta: float) -> void:
	if not is_instance_valid(player) or not is_instance_valid(npc):
		talk_button.hide()
		if _in_dialogue:
			close_dialogue()
		return
	var p := player.global_position
	var n := npc.global_position
	var in_range := Vector2(p.x - n.x, p.z - n.z).length() <= interaction_distance
	talk_button.visible = in_range and not _in_dialogue and npc.dialogue != null and not npc.dialogue.lines.is_empty()
	if _in_dialogue and not in_range:
		close_dialogue()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo():
		if _in_dialogue:
			advance_dialogue()
			get_viewport().set_input_as_handled()
		elif talk_button.visible:
			open_dialogue()
			get_viewport().set_input_as_handled()

func open_dialogue() -> void:
	if not is_instance_valid(player) or not is_instance_valid(npc) or not talk_button.visible or npc.dialogue == null or npc.dialogue.lines.is_empty():
		return
	_in_dialogue = true
	_current_line = 0
	npc.set_talking(true)
	player.set_controls_enabled(false)
	talk_button.hide()
	panel.show()
	_refresh_line()

func _refresh_line() -> void:
	speaker.text = npc.dialogue.speaker_name
	line_label.text = npc.dialogue.lines[_current_line]
	next_button.text = "Finish" if _current_line == npc.dialogue.lines.size() - 1 else "Next"

func advance_dialogue() -> void:
	if not _in_dialogue:
		return
	_current_line += 1
	if _current_line >= npc.dialogue.lines.size():
		close_dialogue()
		dialogue_finished.emit()
	else:
		_refresh_line()

func close_dialogue() -> void:
	if not _in_dialogue:
		return
	_in_dialogue = false
	panel.hide()
	if is_instance_valid(npc):
		npc.set_talking(false)
	if is_instance_valid(player):
		player.set_controls_enabled(true)
