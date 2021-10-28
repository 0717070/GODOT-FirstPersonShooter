extends Spatial

export (bool) var use_raycast = false
#use_raycast: An exported boolean so we can change whether the turret uses objects or raycasting for bullets.
const TURRET_DAMAGE_BULLET = 30
#TURRET_DAMAGE_BULLET: The amount of damage a single bullet scene does.
const TURRET_DAMAGE_RAYCAST = 5
#TURRET_DAMAGE_RAYCAST: The amount of damage a single Raycast bullet does.
const FLASH_TIME = 0.1
#FLASH_TIME: The amount of time (in seconds) the muzzle flash meshes are visible.
var flash_timer = 0
#flash_timer: A variable for tracking how long the muzzle flash meshes have been visible.
const FIRE_TIME = 0.8
#FIRE_TIME: The amount of time (in seconds) needed to fire a bullet.
var fire_timer = 0
#fire_timer: A variable for tracking how much time has passed since the turret last fired.
var node_turret_head = null
#node_turret_head: A variable to hold the Head node.
var node_raycast = null
#node_raycast: A variable to hold the Raycast node attached to the turret's head
var node_flash_one = null
#node_flash_one: A variable to hold the first muzzle flash MeshInstance.
var node_flash_two = null
#node_flash_two: A variable to hold the second muzzle flash MeshInstance.
var ammo_in_turret = 20
#ammo_in_turret: The amount of ammo currently in the turret.
const AMMO_IN_FULL_TURRET = 20
#AMMO_IN_FULL_TURRET: The amount of ammo in a full turret.
const AMMO_RELOAD_TIME = 4
#AMMO_RELOAD_TIME: The amount of time it takes the turret to reload.
var ammo_reload_timer = 0
#ammo_reload_timer: A variable for tracking how long the turret has been reloading.
var current_target = null
#current_target: The turret's current target.
var is_active = false
#is_active: A variable for tracking whether the turret is able to fire at the target.
const PLAYER_HEIGHT = 3
#PLAYER_HEIGHT: The amount of height we're adding to the target so we're not shooting at its feet.
var smoke_particles
#smoke_particles: A variable to hold the smoke particles node.
var turret_health = 60
#turret_health: The amount of health the turret currently has.
const MAX_TURRET_HEALTH = 40
#MAX_TURRET_HEALTH: The amount of health a fully healed turret has.
const DESTROYED_TIME = 20
#DESTROYED_TIME: The amount of time (in seconds) it takes for a destroyed turret to repair itself.
var destroyed_timer = 0
#destroyed_timer: A variable for tracking the amount of time a turret has been destroyed.
var bullet_scene = preload("Bullet_Scene.tscn")
#bullet_scene: The bullet scene the turret fires (same scene as the player's pistol)

func _ready():
	#get the vision area and connect the body_entered and body_exited signals to body_entered_vision and body_exited_vision, respectively.
	$Vision_Area.connect("body_entered", self, "body_entered_vision")
	$Vision_Area.connect("body_exited", self, "body_exited_vision")
	#get all the nodes and assign them to their respective variables.
	node_turret_head = $Head
	node_raycast = $Head/Ray_Cast
	node_flash_one = $Head/Flash
	node_flash_two = $Head/Flash_2
#dd some exceptions to the Raycast so the turret cannot hurt itself.
	node_raycast.add_exception(self)
	node_raycast.add_exception($Base/Static_Body)
	node_raycast.add_exception($Head/Static_Body)
	node_raycast.add_exception($Vision_Area)
#make both flash meshes invisible at start, since we are not going to be firing during _ready.
	node_flash_one.visible = false
	node_flash_two.visible = false
	#get the smoke particles node and assign it to the smoke_particles variable. We also set emitting to false to ensure the particles are not emitting until the turret is broken.
	smoke_particles = $Smoke
	smoke_particles.emitting = false
	#set the turret's health to MAX_TURRET_HEALTH so it starts at full health
	turret_health = MAX_TURRET_HEALTH


func _physics_process(delta):
#check whether the turret is active. If the turret is active, we want to process the firing code.
	if is_active == true:
#if flash_timer is greater than zero, meaning the flash meshes are visible, we want to remove delta from flash_timer. If flash_timer gets to zero or less after we've subtracted delta, we want to hide both of the flash meshes.
		if flash_timer > 0:
			flash_timer -= delta

			if flash_timer <= 0:
				node_flash_one.visible = false
				node_flash_two.visible = false
#check whether the turret has a target. If the turret has a target, we make the turret head look at it, adding PLAYER_HEIGHT so it is not aiming at the player's feet.
		if current_target != null:

			node_turret_head.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0, 1, 0))
#check whether the turret's health is greater than zero. If it is, we then check whether there is ammo in the turret.
			if turret_health > 0:
#check whether fire_timer is greater than zero. If it is, the turret cannot fire and we need to remove delta from fire_timer. If fire_timer is less than or equal to zero, the turret can fire a bullet, so we call the fire_bullet function.
#If there isn't any ammo in the turret, we check whether ammo_reload_timer is greater than zero. If it is, we subtract delta from ammo_reload_timer. If ammo_reload_timer is less than or equal to zero, we set ammo_in_turret to AMMO_IN_FULL_TURRET because the turret has waited long enough to refill its ammo.
				if ammo_in_turret > 0:
					if fire_timer > 0:
						fire_timer -= delta
					else:
						fire_bullet()
				else:
					if ammo_reload_timer > 0:
						ammo_reload_timer -= delta
					else:
						ammo_in_turret = AMMO_IN_FULL_TURRET
#check whether the turret's health is less than or equal to 0 outside of whether it is active or not. If the turret's health is zero or less, we then check whether destroyed_timer is greater than zero. If it is, we subtract delta from destroyed_timer.
	if turret_health <= 0:
#If destroyed_timer is less than or equal to zero, we set turret_health to MAX_TURRET_HEALTH and stop emitting smoke particles by setting smoke_particles.emitting to false.
		if destroyed_timer > 0:
			destroyed_timer -= delta
		else:
			turret_health = MAX_TURRET_HEALTH
			smoke_particles.emitting = false


func fire_bullet():
#check whether the turret is using a raycast
	if use_raycast == true:
		#make the raycast look at the target, ensuring the raycast will hit the target if nothing is in the way.
		node_raycast.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0, 1, 0))

		node_raycast.force_raycast_update()
		#check whether the raycast has collided with anything
		#If it has, then check whether the collided body has the bullet_hit method. 
		if node_raycast.is_colliding():
			var body = node_raycast.get_collider()
			if body.has_method("bullet_hit"):
				body.bullet_hit(TURRET_DAMAGE_RAYCAST, node_raycast.get_collision_point())
	#then subtract 1 from ammo_in_turret.
		ammo_in_turret -= 1

	else:
		#If the turret is not using a raycast, we spawn a bullet object instead.
		var clone = bullet_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)

		clone.global_transform = $Head/Barrel_End.global_transform
		#set the bullet's global transform to the barrel end, scale it up since it's too small, and set its damage and speed using the turret's constant class variables
		clone.scale = Vector3(8, 8, 8)
		clone.BULLET_DAMAGE = TURRET_DAMAGE_BULLET
		clone.BULLET_SPEED = 60
	#then subtract 1 from ammo_in_turret.
		ammo_in_turret -= 1
	#make both of the muzzle flash meshes visible
	node_flash_one.visible = true
	node_flash_two.visible = true
	#set flash_timer and fire_timer to FLASH_TIME and FIRE_TIME, respectively
	flash_timer = FLASH_TIME
	fire_timer = FIRE_TIME
	#check whether the turret has used the last bullet in its ammo
	if ammo_in_turret <= 0:
		#set ammo_reload_timer to AMMO_RELOAD_TIME so the turret reloads.
		ammo_reload_timer = AMMO_RELOAD_TIME


func body_entered_vision(body):
	##check whether the turret currently has a target by checking if current_target is equal to null
	if current_target == null:
		##If the turret does not have a target, we then check whether the body that has just entered the vision Area is a KinematicBody.
		#f the body that just entered the vision Area is a KinematicBody, we set current_target to the body, and set is_active to true.
		if body is KinematicBody:
			current_target = body
			is_active = true


func body_exited_vision(body):
	#check whether the turret has a target. If it does, we then check whether the body that has just left the turret's vision Area is the turret's target.
	if current_target != null:
		#If the body that has just left the vision Area is the turret's current target, we set current_target to null, set is_active to false, and reset all the variables related to firing the turret since the turret no longer has a target to fire at.
		if body == current_target:
			current_target = null
			is_active = false

			flash_timer = 0
			fire_timer = 0
			node_flash_one.visible = false
			node_flash_two.visible = false


func bullet_hit(damage, bullet_hit_pos):
	#subtract however much damage the bullet causes from the turret's health
	turret_health -= damage
#check whether the turret has been destroyed (health being zero or less). If the turret is destroyed, we start emitting the smoke particles and set destroyed_timer to DESTROYED_TIME so the turret has to wait before being repaired.
	if turret_health <= 0:
		smoke_particles.emitting = true
		destroyed_timer = DESTROYED_TIME
