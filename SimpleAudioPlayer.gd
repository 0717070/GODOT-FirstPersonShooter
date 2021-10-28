extends Spatial

var audio_node = null
var should_loop = false
var globals = null

func _ready():
	audio_node = $Audio_Stream_Player
	audio_node.connect("finished", self, "sound_finished")
	audio_node.stop()

	globals = get_node("/root/Globals")

#play_sound expects an audio stream, named audio_stream, to be passed in, 
func play_sound(audio_stream, position=null):
	if audio_stream == null:
		print ("No audio stream passed; cannot play sound")
		globals.created_audio.remove(globals.created_audio.find(self))
		queue_free()
		return

	audio_node.stream = audio_stream
	
	audio_node.play(0.0)

#check to see if the audio player is supposed to loop or not using should_loop. If the audio player is supposed to loop, we play the sound again from the start, at position 0.0. 
func sound_finished():
	if should_loop:
		audio_node.play(0.0)
	else:
		globals.created_audio.remove(globals.created_audio.find(self))
		audio_node.stop()
		queue_free()
