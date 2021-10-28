extends Spatial

export (int, "full size", "small") var kit_size = 0 setget kit_size_change
#kit_size: The size of the health pickup.

# 0 = full size pickup, 1 = small pickup
const HEALTH_AMOUNTS = [70, 30]
#HEALTH_AMMOUNTS: The amount of health each pickup in each size contains.
const RESPAWN_TIME = 20
#RESPAWN_TIME: The amount of time, in seconds, it takes for the health pickup to respawn
var respawn_timer = 0
#respawn_timer: A variable used to track how long the health pickup has been waiting to respawn.
var is_ready = false
#is_ready: A variable to track whether the _ready function has been called or not.
func _ready():
	#onnect the body_entered signal from the Health_Pickup_Trigger to the trigger_body_entered funct
	$Holder/Health_Pickup_Trigger.connect("body_entered", self, "trigger_body_entered")
	#set is_ready to true so we can use the setget function
	is_ready = true
	#hide all the possible kits and their collision shapes using kit_size_change_values
	kit_size_change_values(0, false)
	kit_size_change_values(1, false)
	#make only the kit size we selected visible, calling kit_size_change_values and passing in kit_size and true, so the size at kit_size is enabled
	kit_size_change_values(kit_size, true)


func _physics_process(delta):
	if respawn_timer > 0:
		respawn_timer -= delta

		if respawn_timer <= 0:
			kit_size_change_values(kit_size, true)


func kit_size_change(value):
	#check to see if is_ready is true.
	if is_ready:
		#make whatever kit already assigned to kit_size disabled using kit_size_change_values, passing in kit_size and false.
		kit_size_change_values(kit_size, false)
		kit_size = value
		#assign kit_size to the new value passed in, value. Then we call kit_size_change_values passing in kit_size again, but this time with the second argument as true so we enable it. Because we changed kit_size to the passed in value, this will make whatever kit size was passed in visible.
		kit_size_change_values(kit_size, true)
	else:
		#If is_ready is not true, simply assign kit_size to the passed in value
		kit_size = value


func kit_size_change_values(size, enable):
	#check to see which size was passed in.
	#get the collision shape for the node corresponding to size and disable it based on the enabled passed in argument/variable.
	if size == 0:
		#get the correct Spatial node holding the mesh and set its visibility to enable.
		$Holder/Health_Pickup_Trigger/Shape_Kit.disabled = !enable
		$Holder/Health_Kit.visible = enable
	elif size == 1:
		#get the correct Spatial node holding the mesh and set its visibility to enable.
		$Holder/Health_Pickup_Trigger/Shape_Kit_Small.disabled = !enable
		$Holder/Health_Kit_Small.visible = enable


func trigger_body_entered(body):
	#check whether or not the body that has just entered has a method/function called add_health. If it does, we then call add_health and pass in the health provided by the current kit size.
	if body.has_method("add_health"):
		body.add_health(HEALTH_AMOUNTS[kit_size])
		#set respawn_timer to RESPAWN_TIME so the player has to wait before the player can get health again
		respawn_timer = RESPAWN_TIME
		#call kit_size_change_values, passing in kit_size and false so the kit at kit_size is invisible until it has waited long enough to respawn.
		kit_size_change_values(kit_size, false)





