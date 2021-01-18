tool
extends HBoxContainer

signal option_selected(option)

export var label_text:String = "Options Label" setget set_label
export var list := []

func _ready() -> void:
	var button := $OptionButton
	if button:
		for i in list:
			button.add_item( str(i) )
		button.connect("item_selected", self, "_on_item_selected")


func set_label(text:String):
	if $Label:
		label_text = text
		$Label.text = text


func _on_item_selected(id:int):
	emit_signal("option_selected", str(list[id]) )
	print(name, ": ", list[id])
