extends SpinBox
class_name SpinBoxExt

onready var line = get_line_edit()

func _ready():
	line.connect("text_entered", self, "_on_text_entered")
	connect("value_changed", self, "_on_SpinBox_value_changed")

func _on_text_entered(new_text):
	line.release_focus()

func _on_SpinBox_value_changed(value):
	line.release_focus()
