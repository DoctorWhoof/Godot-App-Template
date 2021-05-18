extends LineEdit
class_name LineEditExt

signal value_committed(new_value)

var silent:= false

func _ready():
	connect("text_entered", self, "_on_text_entered")

func _on_text_entered(new_text):
	release_focus()
	print("new text:", new_text)
	if not silent:
		emit_signal("value_committed", new_text)
	silent = false


