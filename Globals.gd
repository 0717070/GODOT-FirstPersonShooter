extends Node
# ------------------------------------
# All the GUI/UI-related variables

var canvas_layer = null
#canvas_layer: A canvas layer so the GUI/UI created in Globals.gd is always drawn on top.
const DEBUG_DISPLAY_SCENE = preload("res://Debug_Display.tscn")
#DEBUG_DISPLAY: The debug display scene we worked on earlier.
var debug_display = null
#debug_display: A variable to hold the debug display when/if there is one.
# ------------------------------------
const MAIN_MENU_PATH = "res://Main_Menu.tscn"
#MAIN_MENU_PATH: The path to the main menu scene.
const POPUP_SCENE = preload("res://Pause_Popup.tscn")
#POPUP_SCENE: The pop up scene we looked at earlier.
var popup = null
#popup: A variable to hold the pop up scene.
var mouse_sensitivity = 0.08
#mouse_sensitivity: The current sensitivity for our mouse, so we can load it in Player.gd.
var joypad_sensitivity = 2
#joypad_sensitivity: The current sensitivity for our joypad, so we can load it in Player.gd
var respawn_points = null
#respawn_points: A variable to hold all the respawn points in a level
var PlayerScore = 0
#variable for the players score, (current player score starts at 0).

# v All the audio files for the weapons
var audio_clips = {
		"Pistol_shot":preload("res://Audio/pistol.wav"), #pistol shot audio
		"Rifle_shot":preload("res://Audio/rifle.wav"), #Rifle shot audio
		"Gun_cock":preload("res://Audio/gun_semi_auto_rifle_cock_02 (1).wav") #reload weapon audio
}
# The simple audio player scene
const SIMPLE_AUDIO_PLAYER_SCENE = preload("res://Simple_Audio_Player.tscn")
#SIMPLE_AUDIO_PLAYER_SCENE: The simple audio player scene.
# A list to hold all of the created audio nodes
var created_audio = []
#created_audio: A list to hold all the simple audio players Globals.gd has created.

func _ready():
	randomize() #random string of numbers when we use any of the random functions.
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)

func load_new_scene(new_scene_path):
	# Set respawn points to null so when/if we get to a level with no respawn points, we do not respawn at the respawn points in the level prior.
	respawn_points = null
	get_tree().change_scene(new_scene_path)
	for sound in created_audio:
		if (sound != null): #---------------------------
			sound.queue_free()
	created_audio.clear() #---------------------------

func set_debug_display(display_on):
	#displays debug display only when turned on in options menu
	#if debug dislay is not turned on in options menu, do not display
	if display_on == false:
		if debug_display != null:
			debug_display.queue_free()
			debug_display = null
	else:
		#if debug dislay is  turned on in options menu, do  display
		if debug_display == null:
			debug_display = DEBUG_DISPLAY_SCENE.instance()
			canvas_layer.add_child(debug_display)

func _process(delta):
	#pop up scene, when escape button is pressed, close pop up
	if Input.is_action_just_pressed("ui_cancel"):
		#checks globals to see if pop up = null
		if popup == null:
			popup = POPUP_SCENE.instance()

			popup.get_node("Button_quit").connect("pressed", self, "popup_quit")
			popup.connect("popup_hide", self, "popup_closed")
			popup.get_node("Button_resume").connect("pressed", self, "popup_closed")

			canvas_layer.add_child(popup)
			popup.popup_centered()

			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

			get_tree().paused = true

func popup_closed():
	#popup_closed will resume the game and destroy the pop-up if there is one.
	get_tree().paused = false

	if popup != null:
		popup.queue_free()
		popup = null

func popup_quit():
	#popup_quit will resume the game, set the mouse mode to MOUSE_MODE_VISIBLE to ensure the mouse is visible in the main menu, destroy the pop-up if there is one, and change scenes to the main menu.
	get_tree().paused = false

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if popup != null:
		popup.queue_free()
		popup = null

	load_new_scene(MAIN_MENU_PATH)

func get_respawn_position():
	if respawn_points == null: #check if Globals.gd has any respawn_points by checking whether respawn_points is null or not.
		return Vector3(0, 0, 0) #If respawn_points is null, return to position of empty Vector 3 with the position (0, 0, 0).
	else:
		#If respawn_points = not null, we then get a random number between 0 and the number of elements in respawn_points, minus 1.
		var respawn_point = rand_range(0, respawn_points.size() - 1)
		#return the position of the Spatial node at respawn_point position in respawn_points.
		return respawn_points[respawn_point].global_transform.origin

#check whether Globals.gd has an audio clip with the name sound_name in audio_clips. If it does not, we print an error message.
func play_sound(sound_name, loop_sound=false, sound_position=null):
	#If Globals.gd has an audio clip with the name sound_name, then instance/spawn a new SIMPLE_AUDIO_PLAYER_SCENE and assign it to new_audio.
	if audio_clips.has(sound_name):
		var new_audio = SIMPLE_AUDIO_PLAYER_SCENE.instance()
		#We then set should_loop, and add new_audio as a child of Globals.gd.
		new_audio.should_loop = loop_sound

		add_child(new_audio)
		#add the new_audio into the created_audio list to hold all created audios.
		created_audio.append(new_audio)
		#call play_sound, passing in the audio clip associated with sound_name and the sound position.
		new_audio.play_sound(audio_clips[sound_name], sound_position)
	else:
		print ("ERROR: cannot play sound that does not exist in audio_clips!")
	
