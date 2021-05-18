extends CheckBox

signal value_committed(new_value)
signal value_changed(new_value)		#necessary for standard behavior between multiple controls
signal value_is_changing(new_value)	#necessary for standard behavior between multiple controls


var silent:= false
var previous_value = null			#necessary for standard behavior between multiple controls


func _ready() -> void:
	connect("toggled", self, "_on_value_changed")


func _on_value_changed(_value):
	if not silent:
		emit_signal("value_committed", _value)
#	emit_signal("value_changed", _value)
#	emit_signal("value_is_changing", _value)


func _on_Button_toggled(button_pressed) -> void:
	emit_signal("value_changed", button_pressed)
	emit_signal("value_is_changing", button_pressed)
