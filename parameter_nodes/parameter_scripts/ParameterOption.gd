extends ParameterControl

export var initial_value := 0
export var list := []

func _ready() -> void:
	control = $OptionButton
	button_reset = $ButtonReset

	for i in list:
		control.list = list
		control.add_item( str(i) )
	if initial_value != null:
		print (control)
		set_value(initial_value, true) #Initial value should be silent
	_check_default_value()
	_project_hook_up(initial_value)
	button_reset.visible = visible_reset_button

func get_value() -> int:
	return control.selected


func _set_control(_value):
	control.selected = _value


func _check_default_value():
	if control.selected == initial_value:
		button_reset.disabled = true
	else:
		button_reset.disabled = false


func _on_ButtonReset_pressed() -> void:
	set_value(initial_value)


func _on_OptionButton_value_committed(new_value) -> void:
	set_value(new_value)
