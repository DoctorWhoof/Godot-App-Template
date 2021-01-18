tool
extends HBoxContainer

signal value_changed(value)

export var label_text:= "Slider Label" setget set_label
export var value := 0.0
export var min_value:= 0.0
export var max_value:= 100.0
export var step:= 1.0
export var rounded:= false

func _ready() -> void:
	var slider := $Slider
	if slider:
		slider.connect("value_changed", self, "_on_slider_changed")
		slider.value = value
		slider.min_value = min_value
		slider.max_value = max_value
		slider.step = step
		slider.rounded = rounded


func set_label(text:String):
	if $Label:
		label_text = text
		$Label.text = text


func _on_slider_changed(value:float):
	emit_signal("value_changed", value)
