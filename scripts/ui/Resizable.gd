extends Control

export var resize_width := true
export var resize_height := true
export var size_multiplier := 1.0

var original_size:Vector2

func _ready():
	add_to_group("Resizable")
	original_size = rect_size * size_multiplier


func _ui_resize(ui_scale:float):
	if resize_width:
		rect_min_size.x = original_size.x * ui_scale
	elif resize_height:
		rect_min_size.y = original_size.y * ui_scale

