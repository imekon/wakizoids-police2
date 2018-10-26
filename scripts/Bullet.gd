extends KinematicBody2D

const MOVEMENT = 1000.0

var start_time
var owner_ship

func _ready():
	start_time = OS.get_unix_time()

func _physics_process(delta):
	var thrust = MOVEMENT * delta
	var rot = rotation_degrees
	var direction = Vector2(thrust, 0).rotated(deg2rad(rot))
	var collide = move_and_collide(direction)
	if collide != null:
		if collide.collider.is_in_group("mining_ship"):
			collide.collider.get_parent().queue_free()
		elif collide.collider.is_in_group("alien"):
			collide.collider.damage(30)
		queue_free()
	
	var now = OS.get_unix_time()
	if now - start_time > 1:
		queue_free()

func set_owner(own):
	owner_ship = weakref(own)