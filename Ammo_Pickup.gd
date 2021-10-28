extends Spatial #extends Ammo_Pickup Node
#exports the ammunition kits
export (int, "full size", "small") var kit_size = 0 setget kit_size_change
# 0 = full size pickup, 1 = small pickup
const AMMO_AMOUNTS = [4, 1]
#GRENADE_AMOUNTS: The amount of grenades each pickup contains.
const GRENADE_AMOUNTS = [2, 0]
#respawn time of ammunition pick ups = 20 seconds
const RESPAWN_TIME = 20
#respawn timer = 0
var respawn_timer = 0
var is_ready = false

func _ready():
	#body_entered signal is connected from the Ammo_Pickup_Trigger to the trigger_body_entered function.
	#anything that enters the area will trigger the trigger_body_entered function.
	$Holder/Ammo_Pickup_Trigger.connect("body_entered", self, "trigger_body_entered")
	#is_ready equals true for setget function to be usable
	is_ready = true
	#hiding all the collision shapes by using kit_size_change_values. The first argument is the size of the kit, while the second argument is whether to enable or disable the collision shape and mesh at that size.
	kit_size_change_values(0, false)
	kit_size_change_values(1, false)
	kit_size_change_values(kit_size, true)

func _physics_process(delta):
	if respawn_timer > 0:
		respawn_timer -= delta

		if respawn_timer <= 0:
			kit_size_change_values(kit_size, true)


func kit_size_change(value):
	#checking if kit_size_change is ready
	if is_ready:
		kit_size_change_values(kit_size, false)
		kit_size = value

		kit_size_change_values(kit_size, true)
	else:
		kit_size = value


func kit_size_change_values(size, enable):
	#check to see which size has passed (0 or 1)
	if size == 0:
		#gathering the collision shapes and disabling it based on the passed the enable passed arguement. 
		$Holder/Ammo_Pickup_Trigger/Shape_Kit.disabled = !enable
		$Holder/Ammo_Kit.visible = enable
	elif size == 1:
		$Holder/Ammo_Pickup_Trigger/Shape_Kit_Small.disabled = !enable
		$Holder/Ammo_Kit_Small.visible = enable


func trigger_body_entered(body):
	#check whether the body that has entered has function called "add_ammo", if it does, pass in the ammo pickup provided by the kits size
	if body.has_method("add_ammo"):
		body.add_ammo(AMMO_AMOUNTS[kit_size])
		#respawn timer for the ammo_pickup to reset so the player can grab it again. 
		respawn_timer = RESPAWN_TIME
		#kit_size_change_values = false so the ammo pickup is invisible until the player can access it again. 
		kit_size_change_values(kit_size, false)

	if body.has_method("add_grenade"):
		body.add_grenade(GRENADE_AMOUNTS[kit_size])
		respawn_timer = RESPAWN_TIME
		kit_size_change_values(kit_size, false)
