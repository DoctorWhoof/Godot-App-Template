extends HBoxContainer
class_name HDragContainer

export(NodePath) var drag_bar_node
export(NodePath) var panel_left_node
export(NodePath) var panel_right_node

export var bar_safe_margin := 0.05

var panel_left:Control
var panel_right:Control
var drag_bar:Control

var bar_width := 0.0
var bar_position := 0.5
var is_dragging := false

func _enter_tree() -> void:
	panel_left = get_node(panel_left_node)
	panel_right = get_node(panel_right_node)
	drag_bar = get_node(drag_bar_node)
	assert(panel_left, "HDragContainer Error: Left panel node is required")
	assert(panel_right, "HDragContainer Error: Left panel node is required")
	assert(drag_bar, "HDragContainer Error: Drag bar node is required")

	var width:float = panel_left.size_flags_stretch_ratio + panel_right.size_flags_stretch_ratio
	bar_position = panel_left.size_flags_stretch_ratio / width


func _ready() -> void:
	add_to_group("Resizable")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.position.x > rect_size.x * bar_position - bar_width:
				if event.position.x < rect_size.x * bar_position + bar_width:
					is_dragging = true
		if event.pressed == false:
			is_dragging = false

	if event is InputEventMouseMotion:
		if is_dragging:
			bar_position = event.position.x / rect_size.x
			_ui_resize(1.0)


func _ui_resize(ui_scale:float):
	#ui_scale is here just to comply with the Draggable interface, it isn't actually used.
	if bar_position < bar_safe_margin: bar_position = bar_safe_margin
	if bar_position > 1.0 - bar_safe_margin: bar_position = 1.0 - bar_safe_margin

	bar_width = drag_bar.rect_size.x
	var bar_stretch:float = bar_width / rect_size.x

	drag_bar.size_flags_stretch_ratio = bar_stretch
	panel_left.size_flags_stretch_ratio = bar_position - (bar_stretch/2.0)
	panel_right.size_flags_stretch_ratio = 1.0 - bar_position - (bar_stretch/2.0)


