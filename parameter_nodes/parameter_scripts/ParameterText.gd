extends ParameterControl

export var initial_value:= "Text"

func _ready() -> void:
	control = $Text
	button_reset = $ButtonReset

	if initial_value != null:
		set_value(initial_value, true) #Initial value should be silent

	_check_default_value()
	_project_hook_up(initial_value)
	button_reset.visible = visible_reset_button

func get_value() -> String:
	return control.text


func _set_control(_value):
	control.text = _value


func _check_default_value():
	if button_reset:
		if control.text == initial_value:
			button_reset.disabled = true
		else:
			button_reset.disabled = false


func _on_ButtonReset_pressed() -> void:
	control.text = initial_value


func _on_Text_value_committed(new_value) -> void:
	set_value(new_value)
