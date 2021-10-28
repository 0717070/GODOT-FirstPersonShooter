extends Control

func _ready():
	$OS_Label.text = "OS: " + OS.get_name() #set the OS_Label's text to the name provided by OS using the get_name function.
	$Engine_Label.text = "Godot version: " + Engine.get_version_info()["string"] #set the Engine_Label's text to the version info provided by Engine.get_version_info

func _process(delta):
	$FPS_Label.text = "FPS: " + str(Engine.get_frames_per_second()) #set the text of the FPS_Label to Engine.get_frames_per_second, but because get_frames_per_second returns an integer, we have to cast it to a string using str before we can add it to the Label.
