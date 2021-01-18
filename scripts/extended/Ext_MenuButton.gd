extends MenuButton
class_name MenuButtonExt

signal item_pressed(item)

export var list := []
export var item_separation := 12

var original_separation :float

func _ready():
	add_to_group("Resizable")
	original_separation = item_separation

	for i in list:
		get_popup().add_item(str(i))

	get_popup().connect("index_pressed", self, "_on_popup_index_pressed")
	get_popup().set("custom_constants/vseparation", item_separation)


func _on_popup_index_pressed(id:int):
	var item = str( list[id] )
	emit_signal("item_pressed", item)
	print(item)


func _ui_resize(ui_scale:float):
	get_popup().set("custom_constants/vseparation", original_separation * ui_scale)
