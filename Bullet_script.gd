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
	#the area's body_entered signal is set to ouself to call the collide fuction when a body enters the area.
	$Area.connect("body_entered", self, "collided")

func _physics_process(delta):
	#physics_process gets the bullet's local Z axis. translate the entire bullet by that forward direction, multiplying in the speed and delta time. add delta time to our timer and check whether the timer has reached a value as big or greater than our KILL_TIME constant. If it has, we use queue_free to free the bullet.
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * BULLET_SPEED * delta)
	timer += delta
	if timer >= KILL_TIMER:
		queue_free()


func collided(body):
#Bullet's hit_something variable is set to true regardless of whether the body that the bullet collided with has the bullet_hit function/method, it has hit something, needing to make sure the bullet does not hit anythingfree the bullet using queue_free.
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(BULLET_DAMAGE, global_transform)

	hit_something = true
	queue_free()
