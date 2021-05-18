extends OptionButton
class_name OptionButtonExt

#Use this signal to connect to other nodes! It sends the string insted of the ID number
signal value_committed(new_value)

export var list := []

var silent:= false
var item_separation :int
var arrow_margin :int

func _ready():
	add_to_group("Resizable")

	for i in list:
		add_item( str(i) )

	connect("item_selected", self, "_on_item_selected")

	var separation = get("custom_constants/hseparation")
	if separation != null: item_separation = separation

	var margin = get("custom_constants/arrow_margin")
	if margin != null: arrow_margin = margin

	if list.size():
		selected = 0


func _on_item_selected(id:int):
	if not silent:
#		var item = str( list[id] )
		emit_signal("value_committed", id)


func _ui_resize(ui_scale:float):
	if get("custom_constants/hseparation") != null:
		set("custom_constants/hseparation", item_separation * ui_scale)

	if get("custom_constants/arrow_margin") != null:
		set("custom_constants/arrow_margin", arrow_margin * ui_scale)
