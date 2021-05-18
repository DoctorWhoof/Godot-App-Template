#How to use: Load the Project scene as a singleton via Autoload.
#Use the Project singleton to store and retrieve parameters with undo/redo.

extends Node

var data := {}
var undo_stack:= []
var undo_index:= 0
var working_path:String

signal project_loaded()
signal param_changed(param_name, value)

#Creates param if it doesn't exist yet, the sets its value with optional undo
func set_value(param_name:String, value, undoable:=true, silent:=false):
	if not data.has(param_name):
		print("Project Error: ", param_name, " not found")
		return
	var param := data[param_name] as Parameter
	#If Undoable, add undo item to undo stack
	if undoable:
		#Clear undo stack past this point if new value is added
		if undo_index < undo_stack.size()-1:
#			print("tossing redo values")
			for _n in range(undo_stack.size()-undo_index-1):
				var _toss = undo_stack.pop_back()
		#Create undo item
		var item:=UndoItem.new()
		item.param_name = param_name
		if param.value != null:
#			print("previous value:", param.value)
			item.previous_value = param.value
		else:
#			print("no previous! Using default:", param.default_value)
			item.previous_value = param.default_value
		item.value = value
		#Add to stack and update index
		undo_stack.push_back(item)
		undo_index = undo_stack.size()-1
	#Ensure dictionary keys work
	validate_parameter( param_name)
	#Set the new value
	if not param.default_value: param.default_value= value
#	param.previous_value = param.value
	param.value = value
	#Signals
	if not silent:
		emit_signal("param_changed", param_name, value)
		message(param_name, value)
#		print("param_changed signal: ", param_name,", " , value)
	_echo()

#Creates param if it doesn't exist yet, the sets its default value
func set_default_value(param_name:String, default_value):
	validate_parameter(param_name)
	#Set the new value
	var param = data[param_name]
	param.default_value = default_value

#Ensure dictionary keys work
func validate_parameter(param_name:String):
	assert(data.has(param_name), "Project Error: Parameter '"+param_name+"' not found")

#Creates dictionary entries
func create_param(param_name:String, default_value):
	if not data.has(param_name):
		data[param_name] = Parameter.new()
		#Should initial value be undoable? Seems like yes, so we call set_value
		set_value(param_name, default_value)
		#Without this, previous_value would be null
#		data[param_name].previous_value = default_value
		undo_stack.back().previous_value = default_value
	else:
		print("Project Warning: Parameter '"+param_name+"' already exists")

#Returns the value contained in the parameter
func get_value(param_name: String):
	return data[param_name].value

#Returns the default value contained in the parameter
func get_default_value(param_name: String):
	return data[param_name].default_value

#Returns the parameter object itself
func get_parameter(param_name: String) -> Parameter:
	return data[param_name]

#TO DO: Will store the path to an asset in the project, but return the asset itself at runtime
func set_asset(_path, _param_name:String):
	pass

#---------------------------------- I/O ------------------------------------

#Saves a json file with all parameters
func save(path:String, var neat:=true):
	var json := {}
	for param_name in data:
		var p = data[param_name]
		json[param_name]={
			"value":var2str(p.value),
			"default_value":var2str(p.default_value),
			"watchers":p.watchers
		}
#	var neat_json = JSONBeautifier.beautify(JSON.print(json))

	var file = File.new()
	file.open(path, File.WRITE)

#	match neat:
#		true: file.store_string(neat_json)
#		false: file.store_string(JSON.print(json))
	file.store_string(JSON.print(json))

	file.close()

#Parses a json file, creates all parameters, hooks up subscribers
func load(path):
	if path:
		var file := File.new()
		file.open(path, File.READ)
		var json = parse_json(file.get_as_text())
		file.close()

		assert(typeof(json)==TYPE_DICTIONARY, "Project Error: Invalid json file")

		data.clear()
		undo_stack.clear()
		undo_index = 0

		for p in json:
#			print("    ",p)
			data[p]=Parameter.new()
			for key in json[p]:
				var text = str(json[p][key])
				var value = str2var(text)
				match key:
					"value":
						set_value(p,value)
					"default_value":
						set_default_value(p,value)
					"watchers":
						var dict = json[p][key]
						for who in dict:
							var method = str2var(dict[who])
							watch(p, get_node(who), method)
		emit_signal("project_loaded")

#Debugging helper
func _general_type_of(obj)-> String:
	var t = typeof(obj)
	var types = ["nil", "bool", "int", "real", "string", "vector2", "rect2", "vector3", "maxtrix32", "plane", "quat", "aabb",  "matrix3", "transform", "color", "image", "nodepath", "rid", null, "inputevent", "dictionary", "array", "rawarray", "intarray", "realarray", "stringarray", "vector2array", "vector3array", "colorarray", "unknown"]
	if t == TYPE_OBJECT:
		return obj.type_of()
	return types[t]

#------------------------------- Messages ----------------------------------

#Subscribe a Node to watching a parameter, calls method when value changes
func watch(param_name:String, who:Node, method:String):
	assert(data.has(param_name), "Project Error: param name "+param_name+" has not been created")

	var param = data[param_name] as Parameter
	var path = who.get_path()
	param.watchers[path]=method
#	print("Project parameter added: ", param_name)
	#Apply value immediately after subscribing
	if who.has_method(method):
		who.call(method, param.value)

#Sends message to all watchers of a given parameter
func message(param_name:String, value):
	var param = data[param_name]
	for path in param.watchers:
		var who = get_node(path)
		var method_name = param.watchers[path]
		if who.has_method(method_name):
#			print("Message: ", param_name, ", ", value)
			who.call(method_name, value)

#--------------------------------- Undo ------------------------------------

#Convenience function, simply calls _undo_walk(-1)
func undo(silent:=false):
	_undo_walk(-1, silent)

#Convenience function, simply calls _undo_walk(1)
func redo(silent:=false):
	_undo_walk(1, silent)


func _undo_walk(step:int, silent:=false):
	var current_item = undo_stack[undo_index]
	#Step can only be -1 or 1
	if step==0: return
	step = sign(step)
	var max_stack = undo_stack.size()-1
	#proceed with setting proper value
	if not undo_stack.empty():
		if step < 0:
			if get_value(current_item.param_name) != current_item.previous_value:
#				print("Undo: getting value from same item")
				set_value(current_item.param_name, current_item.previous_value, false, silent)
			else:
				if undo_index == 0:
#					print("Undo: Bottom level reached")
					return
				undo_index = clamp(undo_index + step, 0, max_stack)
				var item = undo_stack[undo_index]
				if get_value(item.param_name) != item.value:
					set_value(item.param_name, item.value, false, silent)
				else:
					set_value(item.param_name, item.previous_value, false, silent)
		else:
			if get_value(current_item.param_name) != current_item.value:
#				print("Redo: getting value from same item")
				set_value(current_item.param_name, current_item.value, false, silent)
			else:
				if undo_index == max_stack:
#					print("Redo: Top level reached")
					return
				undo_index = clamp(undo_index + step, 0, max_stack)
				var item = undo_stack[undo_index]
				if get_value(item.param_name) != item.previous_value:
					set_value(item.param_name, item.previous_value, false, silent)
				else:
					set_value(item.param_name, item.value, false, silent)
		_echo()


#----------------------------- Miscellaneous -------------------------------

#Undo keyboard shortcut
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_undo"):
		_undo_walk(-1)
	elif event.is_action_pressed("ui_redo"):
		_undo_walk(1)

#Helps visualize the Undo stack
func _echo():
	for n in range(undo_stack.size()):
		var t := "    "
		if n == undo_index: t = str(undo_index)+"-->"
		Echo.add(t+str(undo_stack[n]))
	Echo.add("--------------------------")
	for p in data:
		Echo.add(p+"="+str(data[p].value))
	Echo.display()

#Resets project
func clear():
	data.clear()
	clear_undo()

#Resets undo stack only
func clear_undo():
	undo_stack.clear()
	undo_index = 0
	_echo()
#----------------------------- Classes -------------------------------

class Parameter:
	var value
	var default_value
	var watchers := {}

	func _to_string() -> String:
		return (
			"; value:"+str(value)+
			",default:"+str(default_value)+
			",watchers:"+str(watchers)
		)


class UndoItem:
	var param_name:String
	var value
	var previous_value

	func _to_string() -> String:
		return param_name+": " + str(value) + "; previous:" + str(previous_value)

