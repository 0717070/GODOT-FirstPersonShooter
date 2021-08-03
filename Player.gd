extends KinematicBody

const GRAVITY = -24.8
#GRAVITY: How strong gravity pulls us down.
var vel = Vector3()
#vel: Our KinematicBody's velocity.
const MAX_SPEED = 20
#MAX_SPEED: The fastest speed we can reach. Once we hit this speed, we will not go any faster.
const JUMP_SPEED = 18
#JUMP_SPEED: how high the player can jump
const ACCEL = 4.5
#ACCEL: How quickly we accelerate. The higher the value, the sooner we get to max speed.
var dir = Vector3()
const DEACCEL= 16
#DEACCEL: How quickly we are going to decelerate. The higher the value, the sooner we will come to a complete stop.
const MAX_SLOPE_ANGLE = 40
#MAX_SLOPE_ANGLE: The steepest angle our KinematicBody will consider as a 'floor'.
var camera
#camera: The Camera node.
var rotation_helper
#rotation_helper: A Spatial node holding everything we want to rotate on the X axis (up and down).
var MOUSE_SENSITIVITY = 0.05
#MOUSE_SENSITIVITY: How sensitive the mouse is. I find a value of 0.05 works well for my mouse, but you may need to change it based on how sensitive your mouse is.
const MAX_SPRINT_SPEED = 30
const SPRINT_ACCEL = 18
var is_sprinting = false

var flashlight

func _ready():
	flashlight = $Rotation_Helper/Flashlight
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)

func process_input(delta):

	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x = 1

	input_movement_vector = input_movement_vector.normalized()

	dir += -cam_xform.basis.z.normalized() * input_movement_vector.y
	dir += cam_xform.basis.x.normalized() * input_movement_vector.x
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------
	
	# ----------------------------------
	# Sprinting
	if Input.is_action_pressed("movement_sprint"):
		is_sprinting = true
	else:
		is_sprinting = false
	# ----------------------------------
	
	# ----------------------------------
	# Turning the flashlight on/off
	if Input.is_action_just_pressed("flashlight"):
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
	# ----------------------------------

func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta*GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:
			accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel,Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
