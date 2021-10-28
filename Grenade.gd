extends RigidBody

const GRENADE_DAMAGE = 60
#GRENADE_DAMAGE: The amount of damage the grenade causes when it explodes.
const GRENADE_TIME = 2
#GRENADE_TIME: The amount of time the grenade takes (in seconds) to explode once it's created/thrown.
var grenade_timer = 0
#grenade_timer: A variable for tracking how long the grenade has been created/thrown.
const EXPLOSION_WAIT_TIME = 0.48
#EXPLOSION_WAIT_TIME: The amount of time needed (in seconds) to wait before we destroy the grenade scene after the explosion
var explosion_wait_timer = 0
#explosion_wait_timer: A variable for tracking how much time has passed since the grenade exploded.
var rigid_shape
#rigid_shape: The CollisionShape for the grenade's RigidBody.
var grenade_mesh
#grenade_mesh: The MeshInstance for the grenade.
var blast_area
#blast_area: The blast Area used to damage things when the grenade explodes.
var explosion_particles
#explosion_particles: The Particles that come out when the grenade explodes.

func _ready():
	#get all the nodes and assign them to the proper class variables.
	#get the CollisionShape and MeshInstance, hide the grenade's mesh and disabling the collision shape when the grenade explodes.
	rigid_shape = $Collision_Shape
	grenade_mesh = $Grenade
	#get the blast Area is so we can damage everything inside it when the grenade explodes. 
	blast_area = $Blast_Area
	#emit particles when the grenade explodes.
	explosion_particles = $Explosion
	#make sure the explosion particles are not emitting, and that they are set to emit in one shot.
	explosion_particles.emitting = false
	explosion_particles.one_shot = true

func _process(delta):
	#check to see if the grenade_timer is less than GRENADE_TIME, If it is,  add delta and return (so the grenade has to wait GRENADE_TIME seconds before exploding, allowing the RigidBody to move around)
	if grenade_timer < GRENADE_TIME:
		grenade_timer += delta
		return
	else:
		#If grenade_timer is at GRENADE_TIMER or higher, we then need to check if the grenade has waited long enough and needs to explode (checking to see if explosion_wait_timer is equal to 0 or less)
		if explosion_wait_timer <= 0:
			#If the grenade has waited long enough to explode, we tell the explosion_particles to emit. Then make the grenade_mesh invisible, and disable rigid_shape, effectively hiding the grenade.
			explosion_particles.emitting = true

			grenade_mesh.visible = false
			rigid_shape.disabled = true
			#set the RigidBody's mode to MODE_STATIC so the grenade does not move
			mode = RigidBody.MODE_STATIC
			#get all the bodies in blast_area, check to see if they have the bullet_hit method/function, and if they do, we call it and pass in GRENADE_DAMAGE and the transform from the body looking at the grenade. This makes it where the bodies exploded by the grenade will explode outwards from the grenade's position.
			var bodies = blast_area.get_overlapping_bodies()
			for body in bodies:
				if body.has_method("bullet_hit"):
					body.bullet_hit(GRENADE_DAMAGE, body.global_transform.looking_at(global_transform.origin, Vector3(0, 1, 0)))

		#check to see if explosion_wait_timer is less than EXPLOSION_WAIT_TIME. If it is, we add delta to explosion_wait_timer.
		if explosion_wait_timer < EXPLOSION_WAIT_TIME:
			explosion_wait_timer += delta
			#check to see if explosion_wait_timer is greater than or equal to EXPLOSION_WAIT_TIME. Because we added delta, this will only be called once. If explosion_wait_timer is greater or equal to EXPLOSION_WAIT_TIME, the grenade has waited long enough to let the Particles play and we can free/destroy the grenade, as we no longer need it.
			if explosion_wait_timer >= EXPLOSION_WAIT_TIME:
				queue_free()
