extends Control

var start_menu
#start_menu: A variable to hold the Start_Menu Panel.
var level_select_menu
#level_select_menu: A variable to hold the Level_Select_Menu Panel.
var options_menu
#options_menu: A variable to hold the Options_Menu Panel.
export (String, FILE) var testing_area_scene
#testing_area_scene: The path to the Testing_Area.tscn file, so we can change to it from this scene.
export (String, FILE) var space_level_scene
#space_level_scene: The path to the Space_Level.tscn file, so we can change to it from this scene.
export (String, FILE) var ruins_level_scene
#ruins_level_scene: The path to the Ruins_Level.tscn file, so we can change to it from this scene.
export (String, FILE) var Doom_level_scene
#The path to the Doom_level_scene file, so we can change to it from this scene.
func _ready():
	#get all the Panel nodes and assign them to the proper variables.
	start_menu = $Start_Menu
	level_select_menu = $Level_Select_Menu
	options_menu = $Options_Menu
	#connect all the buttons pressed signals to their respective [panel_name_here]_button_pressed functions
	$Start_Menu/Button_Start.connect("pressed", self, "start_menu_button_pressed", ["start"])
	$Start_Menu/Button_Open_Godot.connect("pressed", self, "start_menu_button_pressed", ["open_godot"])
	$Start_Menu/Button_Options.connect("pressed", self, "start_menu_button_pressed", ["options"])
	$Start_Menu/Button_Quit.connect("pressed", self, "start_menu_button_pressed", ["quit"])

	$Level_Select_Menu/Button_Back.connect("pressed", self, "level_select_menu_button_pressed", ["back"])
	$Level_Select_Menu/Button_Level_Testing_Area.connect("pressed", self, "level_select_menu_button_pressed", ["testing_scene"])
	$Level_Select_Menu/Button_Level_Space.connect("pressed", self, "level_select_menu_button_pressed", ["space_level"])
	$Level_Select_Menu/Button_Level_Ruins.connect("pressed", self, "level_select_menu_button_pressed", ["ruins_level"])
	$Level_Select_Menu/Doom_level_scene.connect("pressed", self, "level_select_menu_button_pressed", ["Doom_level"])
	
	$Options_Menu/Button_Back.connect("pressed", self, "options_menu_button_pressed", ["back"])
	$Options_Menu/Button_Fullscreen.connect("pressed", self, "options_menu_button_pressed", ["fullscreen"])
	$Options_Menu/Check_Button_VSync.connect("pressed", self, "options_menu_button_pressed", ["vsync"])
	$Options_Menu/Check_Button_Debug.connect("pressed", self, "options_menu_button_pressed", ["debug"])
	#et the mouse mode to MOUSE_MODE_VISIBLE to ensure whenever the player returns to this scene, the mouse will be visible.
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

#	get a singleton, called Globals, set the values for the HSlider nodes so their values line up with the mouse and joypad sensitivity in the singleton.
	var globals = get_node("/root/Globals")
	$Options_Menu/HSlider_Mouse_Sensitivity.value = globals.mouse_sensitivity
	$Options_Menu/HSlider_Joypad_Sensitivity.value = globals.joypad_sensitivity

#check to see which button is pressed.
#Based on the button pressed, either change the currently visible panel, quit the application, or open the Godot website.
func start_menu_button_pressed(button_name):
	if button_name == "start":
		level_select_menu.visible = true
		start_menu.visible = false
	elif button_name == "open_godot":
		OS.shell_open("https://godotengine.org/")
	elif button_name == "options":
		options_menu.visible = true
		start_menu.visible = false
	elif button_name == "quit":
		get_tree().quit()

#level_select_menu_button_pressed, we check to see which button is pressed.
func level_select_menu_button_pressed(button_name):
	#If the back button has been pressed, change the currently visible panels to return to the main menu.
	if button_name == "back":
		start_menu.visible = true
		level_select_menu.visible = false
	elif button_name == "testing_scene":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(testing_area_scene)
	elif button_name == "space_level":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(space_level_scene)
	elif button_name == "ruins_level":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(ruins_level_scene)
	elif button_name == "Doom_level":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(Doom_level_scene)
#
func options_menu_button_pressed(button_name):
	if button_name == "back":
		start_menu.visible = true
		options_menu.visible = false
	elif button_name == "fullscreen":
		OS.window_fullscreen = !OS.window_fullscreen
	elif button_name == "vsync":
		OS.vsync_enabled = $Options_Menu/Check_Button_VSync.pressed
	elif button_name == "debug":
		get_node("/root/Globals").set_debug_display($Options_Menu/Check_Button_Debug.pressed)

#call set_mouse_and_joypad_sensitivity so the singleton (Globals.gd) has the values from the HSlider nodes. Then, we tell the singleton to change nodes using its load_new_scene function, passing in the file path of the scene the player has selected.
func set_mouse_and_joypad_sensitivity():
	var globals = get_node("/root/Globals")
	globals.mouse_sensitivity = $Options_Menu/HSlider_Mouse_Sensitivity.value
	globals.joypad_sensitivity = $Options_Menu/HSlider_Joypad_Sensitivity.value
