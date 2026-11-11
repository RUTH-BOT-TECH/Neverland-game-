extends Control
## Lightweight prototype: one finger per joystick, look, or jump area.
signal move_changed(value: Vector2)
signal look_dragged(delta: Vector2)
signal jump_pressed

var stick_touch := -1
var look_touch := -1
var jump_touch := -1
var stick_value := Vector2.ZERO
var last_look_position := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		stick_touch = -1
		look_touch = -1
		jump_touch = -1
		stick_value = Vector2.ZERO
		move_changed.emit(stick_value)
		queue_redraw()

func _radius() -> float:
	return minf(size.x, size.y) * 0.105

func _stick_center() -> Vector2:
	return Vector2(size.x * 0.15, size.y * 0.78)

func _jump_center() -> Vector2:
	return Vector2(size.x * 0.89, size.y * 0.78)

func _local_position(viewport_position: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * viewport_position

func _set_stick(position: Vector2) -> void:
	stick_value = ((position - _stick_center()) / _radius()).limit_length(1.0)
	move_changed.emit(stick_value)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		var position := _local_position(touch.position)
		if touch.pressed:
			if position.distance_to(_jump_center()) <= _radius() * 0.85 and jump_touch == -1:
				jump_touch = touch.index
				jump_pressed.emit()
			elif position.distance_to(_stick_center()) <= _radius() * 1.5 and stick_touch == -1:
				stick_touch = touch.index
				_set_stick(position)
			elif position.x > size.x * 0.4 and look_touch == -1:
				look_touch = touch.index
				last_look_position = position
		else:
			if touch.index == stick_touch:
				stick_touch = -1
				stick_value = Vector2.ZERO
				move_changed.emit(stick_value)
			if touch.index == look_touch:
				look_touch = -1
			if touch.index == jump_touch:
				jump_touch = -1
		queue_redraw()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		var position := _local_position(drag.position)
		if drag.index == stick_touch:
			_set_stick(position)
		elif drag.index == look_touch:
			look_dragged.emit(position - last_look_position)
			last_look_position = position

func _draw() -> void:
	var radius := _radius()
	draw_circle(_stick_center(), radius, Color(0.04, 0.07, 0.09, 0.42))
	draw_arc(_stick_center(), radius, 0.0, TAU, 48, Color(0.9, 0.95, 1.0, 0.55), 2.0)
	draw_circle(_stick_center() + stick_value * radius * 0.65, radius * 0.36, Color(0.82, 0.9, 1.0, 0.55))
	draw_circle(_jump_center(), radius * 0.75, Color(0.12, 0.23, 0.28, 0.65))
	draw_arc(_jump_center(), radius * 0.75, 0.0, TAU, 48, Color(0.9, 0.95, 1.0, 0.7), 2.0)
	var font := ThemeDB.fallback_font
	var font_size := maxi(12, int(radius * 0.28))
	var word := "JUMP"
	var text_size := font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	draw_string(font, _jump_center() + Vector2(-text_size.x / 2.0, text_size.y * 0.3), word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
