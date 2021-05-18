extends HSlider

signal value_committed(new_value)

var silent := false
var is_sliding := false
var previous_value = null

#func _ready() -> void:
#	previous_value = value


func _on_Slider_value_changed(new_value: float) -> void:
	#called when user is "sliding" the value. We don't want to spam value_committed, so we wait for mouse released with the _on_gui_input method.
#	if not previous_value: previous_value = value
	is_sliding = true
	check_and_send_signal(new_value)


func _on_Slider_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.pressed:
			#Mouse released after sliding: signal is finally emitted
			if is_sliding:
				is_sliding = false
				check_and_send_signal(value)


func check_and_send_signal(new_value:float):
	if not silent:
		if not is_sliding:
			if previous_value != new_value:
				emit_signal("value_committed", new_value)
				previous_value = new_value
#				print("Commit")
#			else:
#				print("Previous: ", previous_value, "; new: ", new_value)
