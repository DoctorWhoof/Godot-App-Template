extends OptionButton
class_name OptionButtonExt

#Use this signal to connect to other nodes! It sends the string insted of the ID number
signal option_selected(option)

export var list := []

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

	selected = 0


func _on_item_selected(id:int):
	var item = str( list[id] )
	emit_signal("option_selected", item)
	print(item)


func _ui_resize(ui_scale:float):
	if get("custom_constants/hseparation") != null:
		set("custom_constants/hseparation", item_separation * ui_scale)

	if get("custom_constants/arrow_margin") != null:
		set("custom_constants/arrow_margin", arrow_margin * ui_scale)
