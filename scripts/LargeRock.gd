extends RigidBody2D

const ACCELERATION = 150

func _ready():
	var angle = randf() * 360.0
	apply_impulse(Vector2(), Vector2(0, -ACCELERATION).rotated(deg2rad(angle)))

func on_body_entered(body):
	if body.is_in_group("bullet"):
		# something wrong here...
		var owner_ship = body.owner_ship.get_ref()
		if owner_ship:
			if owner_ship.is_in_group("mining"):
				owner_ship.add_credit(20)
		body.queue_free()
		queue_free()
