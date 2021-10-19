extends Spatial

export (bool) var use_raycast = false
#use_raycast: An exported boolean so we can change whether the turret uses objects or raycasting for bullets.
const Robot_DAMAGE_BULLET = 10
#Robot_DAMAGE_BULLET: The amount of damage a single bullet scene does.
const Robot_DAMAGE_RAYCAST = 5
#Robot_DAMAGE_RAYCAST: The amount of damage a single Raycast bullet does.
const FLASH_TIME = 0.1
#FLASH_TIME: The amount of time (in seconds) the muzzle flash meshes are visible.
var flash_timer = 0
#flash_timer: A variable for tracking how long the muzzle flash meshes have been visible.
const FIRE_TIME = 0.8
#FIRE_TIME: The amount of time (in seconds) needed to fire a bullet.
var fire_timer = 0
#fire_timer: A variable for tracking how much time has passed since the Robot last fired.
var node_Robot_head = null
#node_Robot_head: A variable to hold the Head node.
var node_raycast = null
#node_raycast: A variable to hold the Raycast node attached to the Robot's head
var node_flash_one = null
#node_flash_one: A variable to hold the first muzzle flash MeshInstance.
var node_flash_two = null
#node_flash_two: A variable to hold the second muzzle flash MeshInstance.
var ammo_in_Robot = 20
#ammo_in_Robot: The amount of ammo currently in the Robot.
const AMMO_IN_FULL_Robot = 20
#AMMO_IN_FULL_Robot: The amount of ammo in a full Robot.
const AMMO_RELOAD_TIME = 4
#AMMO_RELOAD_TIME: The amount of time it takes the Robot to reload.
var ammo_reload_timer = 0
#ammo_reload_timer: A variable for tracking how long the Robot has been reloading.
var current_target = null
#current_target: The Robot's current target.
var is_active = false
#is_active: A variable for tracking whether the Robot is able to fire at the target.
const PLAYER_HEIGHT = 3
#PLAYER_HEIGHT: The amount of height we're adding to the target so we're not shooting at its feet.
var smoke_particles
#smoke_particles: A variable to hold the smoke particles node.
var Robot_health = 60
#Robot_health: The amount of health the Robot currently has.
const MAX_Robot_HEALTH = 40
#MAX_Robot_HEALTH: The amount of health a fully healed Robot has.
const DESTROYED_TIME = 20
#DESTROYED_TIME: The amount of time (in seconds) it takes for a destroyed Robot to repair itself.
var destroyed_timer = 0
#destroyed_timer: A variable for tracking the amount of time a Robot has been destroyed.
var bullet_scene = preload("Bullet_Scene.tscn")
#bullet_scene: The bullet scene the Robot fires (same scene as the player's pistol)

func fire_bullet():
		var clone = bullet_scene.instance()
		var scene_root = get_tree().root.get_children()[0]
		scene_root.add_child(clone)

		clone.global_transform = $Head/Barrel_End.global_transform
		clone.scale = Vector3(8, 8, 8)
		clone.BULLET_DAMAGE = Robot_DAMAGE_BULLET
		clone.BULLET_SPEED = 60

		ammo_in_Robot -= 1

	

	
