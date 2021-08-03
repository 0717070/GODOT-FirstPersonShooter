extends Spatial

var BULLET_SPEED = 70
#BULLET_SPEED: The speed at which the bullet travels.
var BULLET_DAMAGE = 15
#BULLET_DAMAGE: The damage the bullet will cause to anything with which it collides.

const KILL_TIMER = 4
#KILL_TIMER: How long the bullet can last without hitting anything.
var timer = 0
#timer: A float for tracking how long the bullet has been alive.

var hit_something = false
#hit_something: A boolean for tracking whether or not we've hit something.

func _ready():
	$Area.connect("body_entered", self, "collided")


func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * BULLET_SPEED * delta)

	timer += delta
	if timer >= KILL_TIMER:
		queue_free()


func collided(body):
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(BULLET_DAMAGE, global_transform)

	hit_something = true
	queue_free()
