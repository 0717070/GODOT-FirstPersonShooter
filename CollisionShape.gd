extends CollisionShape

func _colliding(area): # code for win scene?
	if area.is_in_group("exit"):
		get_tree().change_scene("res://WinScene.tscn")
		print("winning")
