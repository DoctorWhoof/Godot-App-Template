extends ParameterControl


export var initial_value:= false

func _ready() -> void:
	control = $Button
	button_reset = $ButtonReset
	if initial_value != null:
		set_value(initial_value, true) #Initial value should be silent
	_check_default_value()
	_project_hook_up(initial_value)
	button_reset.visible = visible_reset_button


func get_value() -> bool:
	return $Button.pressed


func _set_control(_value):
	control.pressed = _value


func _on_Button_value_committed(new_value) -> void:
#	var int_value:int = 0
#	if new_value==true: int_value = 1
#	emit_signal("value_changed", int_value, param_name)
#	emit_signal("value_is_changing", int_value, param_name)
	emit_signal("value_changed", new_value, param_name)
	emit_signal("value_is_changing", new_value, param_name)
	_check_default_value()


func _check_default_value():
	if button_reset:
		if control.pressed == initial_value:
			button_reset.disabled = true
		else:
			button_reset.disabled = false



func _on_ButtonReset_pressed() -> void:
	set_value(initial_value)
