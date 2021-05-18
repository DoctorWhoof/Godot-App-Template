extends ParameterControl

export var initial_value := Vector2()
export var min_value:= 0.0
export var max_value:= 100.0
export var step:= 0.001
export var rounded:= false
var previous_value:= Vector2()

var control_B

func _ready() -> void:
	button_reset = $ButtonReset
	control = $SliderX
	if control:
		control.min_value = min_value
		control.max_value = max_value
		control.step = step
		control.rounded = rounded
	control_B = $SliderY
	if control_B:
		control_B.min_value = min_value
		control_B.max_value = max_value
		control_B.step = step
		control_B.rounded = rounded
	if initial_value != null:
		set_value(initial_value, true) #Initial value should be silent
	_check_default_value()
	_project_hook_up(initial_value)
	button_reset.visible = visible_reset_button


func get_value()->Vector2:
	return Vector2(control.value, control_B.value)


func _set_control(_value):
	previous_value.x = control.value
	previous_value.y = control_B.value
	control.value = clamp(_value.x, min_value, max_value)
	control_B.value = clamp(_value.y, min_value, max_value)


func _check_default_value():
	if control.value == initial_value.x:
		if control_B.value == initial_value.y:
			button_reset.disabled = true
			return
	button_reset.disabled = false


func _on_ButtonReset_pressed() -> void:
	set_value(initial_value)


func _on_Slider_value_committed(_value) -> void:
	if _value != previous_value:
		set_value(_value)


func _on_Slider_value_changed(_value: float) -> void:
	emit_signal("value_is_changing", _value, param_name)


#"value_changed" (emitted by set_value) is undo friendly, unlike "value_is_changing",
#since it doesn't change until a value is comitted (instead of mid-sliding)

func _on_SliderX_value_committed(new_value:float) -> void:
	if new_value != previous_value.x:
		set_value(Vector2(new_value, $SliderY.value))


func _on_SliderY_value_committed(new_value:float) -> void:
	if new_value != previous_value.y:
		set_value(Vector2($SliderX.value, new_value))

#If spinbox is in mid-sliding we just relay the signal here,
#but we do NOT emit a "value_changed" signal since that would spam the undo stack

func _on_SliderX_value_changed(new_value: float) -> void:
	if new_value != previous_value.x:
		var vec := Vector2(new_value, $SliderY.value)
		emit_signal("value_is_changing", vec, param_name)


func _on_SliderY_value_changed(new_value: float) -> void:
	if new_value != previous_value.y:
		var vec := Vector2($SliderX.value, new_value)
		emit_signal("value_is_changing", vec, param_name)
