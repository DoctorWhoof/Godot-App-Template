extends ParameterControl

export var initial_value := 1.0
export var min_value:= 0.0
export var max_value:= 100.0
export var step:= 0.000001
export var rounded:= false

func _ready() -> void:
	control = $Slider
	button_reset = $ButtonReset
	value_label = $ValueLabel

	control.min_value = min_value
	control.max_value = max_value
	control.step = step
	control.rounded = rounded
	if initial_value != null:
		set_value(initial_value, true) #Initial value should be silent

	_update_value_label()
	_project_hook_up(initial_value)
	button_reset.visible = visible_reset_button


func get_value():
	return control.value


func _set_control(_value):
	control.value = clamp(_value, min_value, max_value)


func _update_value_label():
	if value_label:
		if rounded:
			value_label.text = ":"+"%d"%control.value
		else:
			value_label.text = ":"+"%1.3f"%control.value    #format to 3 decimals


func _check_default_value():
	if control.value > initial_value-0.0001 and control.value < initial_value+0.0001:
		button_reset.disabled = true
	else:
		button_reset.disabled = false


func _on_ButtonReset_pressed() -> void:
	set_value(initial_value)


func _on_Slider_value_committed(_value) -> void:
	set_value(_value)


func _on_Slider_value_changed(_value: float) -> void:
	emit_signal("value_is_changing", _value, param_name)
	_update_value_label()
