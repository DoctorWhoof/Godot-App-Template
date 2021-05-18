extends HBoxContainer
class_name ParameterControl

signal value_changed(value, param_name)
signal value_is_changing(value, param_name)

export var label_text:= "Label" setget set_label
export var param_name := ""
export var auto_watch := false
export var visible_reset_button := true

#These vars Need to be populated by _onready on each subclass
var control
var button_reset
var value_label
#Required overrides:
func _ready(): pass
func get_value(): pass
func _set_control(_value): pass
func _set_initial_value(_value):pass
func _update_value_label():	pass
func _check_default_value(): pass


func set_value(new_value, silent:=false):
	if silent:
		control.silent = true
	else:
		emit_signal("value_changed", new_value, param_name)
	_set_control(new_value)
	yield(get_tree(), "idle_frame")
	control.silent = false
	_update_value_label()
	_check_default_value()


func set_default(new_default):
	if get("initial_value"):
		set("initial_value", new_default)
	control.previous_value = new_default
	print("setting ", param_name, " initial to ", control.previous_value)


func set_label(text:String):
	if $Label:
		label_text = text
		$Label.text = text


func _project_hook_up(initial_value):
	if auto_watch:
		assert(param_name, "Parameter error: no param_name set")
		Project.create_param(param_name, initial_value)
		Project.watch(param_name, self, "_on_project_value_changed")
		connect("value_changed", self, "_on_value_changed")


func _on_project_value_changed(_value):
	set_value(_value, true) # This needs to be "silent"


func _on_value_changed(_value, _param_name):
	Project.set_value(_param_name, _value)
