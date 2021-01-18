tool
extends HBoxContainer

signal toggled(pressed)

export var label_text:String = "Options Label" setget set_label

func _ready() -> void:
	var button := $Button
	if button:
		button.connect("toggled", self, "_on_checkbox_toggled")


func set_label(text:String):
	if $Label:
		label_text = text
		$Label.text = text


func _on_checkbox_toggled(pressed:bool):
	emit_signal("toggled", pressed)
	print(name,": ", pressed)
