extends CanvasLayer

export var initial_visibility := false
export var h_align := Label.ALIGN_RIGHT
export var v_align := Label.VALIGN_TOP

var label:Label
var tempText := ""


func _ready():
	label = get_node("Label") as Label
	label.visible = initial_visibility
	label.align = h_align
	label.valign = v_align


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_echo"):
		label.visible = !label.visible


func display() -> void:
	label.text = tempText
	tempText = ""
	label.update()


func add( text ):
	text = String( text )
	tempText += ( text + "\n" )


