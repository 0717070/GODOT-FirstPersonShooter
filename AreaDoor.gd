extends Area
var AreaEntered = false
var DoorOpen = false

func _physics_process(delta):
	
	if Input.is_action_just_pressed("ui_E"):
		if AreaEntered ==  true:
			
			if DoorOpen == false:
				$Testing_Area/Rot_Point.rotate_y(rad2deg(90))
				DoorOpen = true
				
			elif DoorOpen == true:
				$Testing_Area/Rot_Point.rotate_y(-90)
				DoorOpen = false






func _on_AreaDoor_body_entered(body):
	if body.name == "Player":
		AreaEntered = true
		
		


func _on_AreaDoor_body_exited(body):
	if body.name == "Player":
		AreaEntered = false
