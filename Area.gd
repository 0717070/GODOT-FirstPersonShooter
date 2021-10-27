extends KinematicBody

func _colliding(area): # connecting to win scene?
	if area.is_in_group("exit"):
		get_tree().change_scene("res://WinScene.tscn")
		print("winning")
