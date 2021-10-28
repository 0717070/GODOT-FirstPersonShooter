extends Panel

func _ready():
	#button for main menu
	for button in $HUD.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
		print(button)
	
func _on_Button_pressed(scene_to_load):
	#sets mouse to visible so the player can click return to main menu 
	print("Changing Scene...")
	print(scene_to_load)
	get_tree().change_scene(scene_to_load)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
