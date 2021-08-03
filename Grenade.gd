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
	rigid_shape = $Collision_Shape
	grenade_mesh = $Grenade
	blast_area = $Blast_Area
	explosion_particles = $Explosion

	explosion_particles.emitting = false
	explosion_particles.one_shot = true

func _process(delta):

	if grenade_timer < GRENADE_TIME:
		grenade_timer += delta
		return
	else:
		if explosion_wait_timer <= 0:
			explosion_particles.emitting = true

			grenade_mesh.visible = false
			rigid_shape.disabled = true

			mode = RigidBody.MODE_STATIC

			var bodies = blast_area.get_overlapping_bodies()
			for body in bodies:
				if body.has_method("bullet_hit"):
					body.bullet_hit(GRENADE_DAMAGE, body.global_transform.looking_at(global_transform.origin, Vector3(0, 1, 0)))

			# This would be the perfect place to play a sound!


		if explosion_wait_timer < EXPLOSION_WAIT_TIME:
			explosion_wait_timer += delta

			if explosion_wait_timer >= EXPLOSION_WAIT_TIME:
				queue_free()
