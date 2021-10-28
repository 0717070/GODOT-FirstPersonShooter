extends AnimationPlayer

# Structure -> Animation name :[Connecting Animation states]
var states = {
#states: A dictionary for holding our animation states.
	"Idle_unarmed":["Knife_equip", "Pistol_equip", "Rifle_equip", "Idle_unarmed"],

	"Pistol_equip":["Pistol_idle"],
	"Pistol_fire":["Pistol_idle"],
	"Pistol_idle":["Pistol_fire", "Pistol_reload", "Pistol_unequip", "Pistol_idle"],
	"Pistol_reload":["Pistol_idle"],
	"Pistol_unequip":["Idle_unarmed"],

	"Rifle_equip":["Rifle_idle"],
	"Rifle_fire":["Rifle_idle"],
	"Rifle_idle":["Rifle_fire", "Rifle_reload", "Rifle_unequip", "Rifle_idle"],
	"Rifle_reload":["Rifle_idle"],
	"Rifle_unequip":["Idle_unarmed"],

	"Knife_equip":["Knife_idle"],
	"Knife_fire":["Knife_idle"],
	"Knife_idle":["Knife_fire", "Knife_unequip", "Knife_idle"],
	"Knife_unequip":["Idle_unarmed"],
}

var animation_speeds = {
#animation_speeds: A dictionary for holding all the speeds at which we want to play our animations.
	"Idle_unarmed":1,

	"Pistol_equip":1.4,
	"Pistol_fire":1.8,
	"Pistol_idle":1,
	"Pistol_reload":1,
	"Pistol_unequip":1.4,

	"Rifle_equip":2,
	"Rifle_fire":6,
	"Rifle_idle":1,
	"Rifle_reload":1.45,
	"Rifle_unequip":2,

	"Knife_equip":1,
	"Knife_fire":1.35,
	"Knife_idle":1,
	"Knife_unequip":1,
}

var current_state = null
#current_state: A variable for holding the name of the animation state we are currently in.
var callback_function = null
#callback_function: A variable for holding the callback function. 

func _ready():
	#setting the animation to Idle_unarmed using the set_animation function, so we for sure start in that animation.
	set_animation("Idle_unarmed")
	#connecting the animation_finished signal to this script and assign it to call animation_ended
	connect("animation_finished", self, "animation_ended")

func set_animation(animation_name):
	#check if the passed in animation name is the same name as the animation currently playing. If they are the same, then we write a message to the console and return true.
	if animation_name == current_state:
		print ("AnimationPlayer_Manager.gd -- WARNING: animation is already ", animation_name)
		return true


	if has_animation(animation_name) == true:
		#checking if AnimationPlayer has an animation with the name animation_name using has_animation. If it does not, we return false.
		if current_state != null:
			var possible_animations = states[current_state]
			if animation_name in possible_animations:
				current_state = animation_name
				play(animation_name, -1, animation_speeds[animation_name])
				return true
			else:
				print ("AnimationPlayer_Manager.gd -- WARNING: Cannot change to ", animation_name, " from ", current_state)
				return false
		else:
			#checking if the current_state is set. If we have a state in current_state, then we get all the possible states we can transition to.
			current_state = animation_name
			#If the animation name is in the list of possible transitions, we set current_state to the passed in animation (animation_name), telling the AnimationPlayer to play the animation with a blend time of -1 at the speed set in animation_speeds and return true.
			play(animation_name, -1, animation_speeds[animation_name])
			return true
	return false


func animation_ended(anim_name):
	#animation_ended is the function that will be called by AnimationPlayer when it's done playing an animation.

	# UNARMED transitions
	if current_state == "Idle_unarmed":
		pass
	# KNIFE transitions
	elif current_state == "Knife_equip":
		set_animation("Knife_idle")
	elif current_state == "Knife_idle":
		pass
	elif current_state == "Knife_fire":
		set_animation("Knife_idle")
	elif current_state == "Knife_unequip":
		set_animation("Idle_unarmed")
	# PISTOL transitions
	elif current_state == "Pistol_equip":
		set_animation("Pistol_idle")
	elif current_state == "Pistol_idle":
		pass
	elif current_state == "Pistol_fire":
		set_animation("Pistol_idle")
	elif current_state == "Pistol_unequip":
		set_animation("Idle_unarmed")
	elif current_state == "Pistol_reload":
		set_animation("Pistol_idle")
	# RIFLE transitions
	elif current_state == "Rifle_equip":
		set_animation("Rifle_idle")
	elif current_state == "Rifle_idle":
		pass;
	elif current_state == "Rifle_fire":
		set_animation("Rifle_idle")
	elif current_state == "Rifle_unequip":
		set_animation("Idle_unarmed")
	elif current_state == "Rifle_reload":
		set_animation("Rifle_idle")

func animation_callback():
	#The animation_callback function which is called by a call method track in our animations. If there is a FuncRef assigned to callback_function, then it can call that passed in function. If we do not have a FuncRef assigned to callback_function, we print out a warning to the console.
	if callback_function == null:
		print ("AnimationPlayer_Manager.gd -- WARNING: No callback function for the animation to call!")
	else:
		callback_function.call_func()
