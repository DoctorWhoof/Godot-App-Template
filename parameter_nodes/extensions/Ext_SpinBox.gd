extends SpinBox
class_name SpinBoxExt

signal value_committed(new_value)

onready var line = get_line_edit()
var silent:= false
#var previous_value:float
var ui_interaction_value:float
var is_sliding:= false
var previous_value = null

func _ready():
	line.connect("text_entered", self, "_on_text_entered")
	connect("value_changed", self, "_on_value_changed")
	connect("gui_input", self, "_on_gui_input")

func _on_text_entered(_new_text):
	line.release_focus()
	var new_value = clamp(float(_new_text), min_value, max_value)
	#Skip signal if value turns out to be the same, i.e. if you type letters att he end and they get trimmed
	if new_value != value:
		check_and_send_signal(new_value)

func _on_value_changed(_value):
	#called when user is "sliding" the value. We don't want to spam value_committed, so we wait for mouse released with the _on_gui_input method.
	line.release_focus()
	is_sliding = true
	check_and_send_signal(_value)

func _on_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		if not event.pressed:
			#Mouse released after sliding: signal is finally emitted
			if is_sliding:
				is_sliding = false
				check_and_send_signal(value)

func check_and_send_signal(new_value:float):
	if not silent:
		if not is_sliding:
#			if previous_value != new_value:
			emit_signal("value_committed", new_value)
#			previous_value = new_value

