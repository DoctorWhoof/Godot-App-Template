extends Control
#Must be placed at the root node

signal ui_scale_changed(new_scale)

export var ui_scale_increment := .25
export var ui_scale_min := 1.0
export var ui_scale_max := 4.0

export var font_default:DynamicFont
export var font_bold:DynamicFont

var default_font_size:float
var bold_font_size:float
var ui_scale := 1.5
var default_ui_scale := 1.5
var config:ConfigFile

func _ready():
	#Ensures fonts are defined, and stores their initial size
	assert(font_default, "MainControl Error: Default font not found.\n")
	assert(font_bold, "MainControl Error: Bold font not found.\n")
	default_font_size = font_default.size
	bold_font_size = font_bold.size

	#Load and process config file
	config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	if err == OK:
		print("Config file loaded")
	else:
		print("Config file not found, initializing")
		config.set_value("ui", "scale", ui_scale)
	ui_scale = config.get_value("ui", "scale", default_ui_scale)

	#Wait a frame just be 100% sure everything is ready, then apply ui scale
	yield(get_tree(), "idle_frame")
	resize_ui()


func _input(event:InputEvent):
	if event.is_action_pressed("ui_scale_up"):
		ui_scale += ui_scale_increment
		resize_ui()
	elif event.is_action_pressed("ui_scale_down"):
		ui_scale -= ui_scale_increment
		resize_ui()
	elif event.is_action_pressed("ui_scale_reset"):
		ui_scale = default_ui_scale
		resize_ui()


func resize_ui():
	ui_scale = clamp(ui_scale, ui_scale_min, ui_scale_max)
	config.set_value("ui", "scale", ui_scale)
	font_default.size = default_font_size * ui_scale
	font_bold.size = bold_font_size * ui_scale
	print("UI Size:", ui_scale)
	for node in get_tree().get_nodes_in_group("Resizable"):
		#I'm not checking if "_ui_resize" method exists because I want the error!
		node._ui_resize(ui_scale)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		config.save("user://config.cfg")
		print("Quit: Auto saving session state")
