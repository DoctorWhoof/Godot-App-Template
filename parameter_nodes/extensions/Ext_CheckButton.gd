extends CheckButton

signal value_committed(new_value)
signal value_changed(new_value)	#necessary for standard behavior between multiple controls

var silent:= false


func _ready() -> void:
	connect("toggled", self, "_on_value_changed")


func _on_value_changed(_value):
	if not silent:
		emit_signal("value_committed", _value)
	emit_signal("value_changed", _value)
