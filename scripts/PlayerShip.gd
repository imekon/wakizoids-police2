extends KinematicBody2D

const MOVEMENT = 700.0

var thrust : float = 0.0
var score : int
var energy : float
var shields : float
var last_fired = 0
var fire_cycle = 0

onready var firing_position = $FiringPosition
onready var left_firing = $LeftPosition
onready var right_firing = $RightPosition

onready var bullet_resource = load("res://scenes/Bullet.tscn")

signal player_dead

func _ready():
	score = 0
	energy = 500
	shields = 200

func _physics_process(delta):
	var moving = false
	var angle = 0.0

	if Input.is_action_pressed("ui_forwards"):
		if energy > 30:
			thrust = MOVEMENT * delta
			energy -= 2
	if Input.is_action_pressed("ui_backwards"):
		if energy > 30:
			thrust = -MOVEMENT * delta * 0.25
			energy -= 2
	if Input.is_action_pressed("ui_left"):
		if energy > 30:
			angle = -2
			energy -= 1
	if Input.is_action_pressed("ui_right"):
		if energy > 30:
			angle = 2
			energy -= 1
		
	if Input.is_action_pressed("ui_fire"):
		fire()
	
	var rot = rotation_degrees

	var direction = Vector2(thrust, 0).rotated(deg2rad(rot))
	var collide = move_and_collide(direction)
	if collide != null:
		process_collision(collide)
		
	rotate(deg2rad(angle))

	if thrust > 1.0:
		thrust *= 0.99
	
	if energy < 500:
		energy += 40 * delta
	
func add_credit(amount):
	pass
	
func damage(amount):
	if shields - amount > 0:
		shields -= amount
		return
		
	shields = 0
	var hit = amount - shields
	
	if energy - hit > 0:
		energy -= hit
		return
		
	energy = 0
	emit_signal("player_dead")
	
func fire():
	var now = OS.get_ticks_msec()
	if now - last_fired > 100:
		if energy > 50:
			var bullet = bullet_resource.instance()
			bullet.set_owner(self)
			match fire_cycle:
				0:
					bullet.position = firing_position.global_position
				1:
					bullet.position = left_firing.global_position
				2:
					bullet.position = right_firing.global_position
			fire_cycle += 1
			if fire_cycle > 2:
				fire_cycle = 0
			bullet.rotate(rotation)
			get_parent().add_child(bullet)
			last_fired = now
			energy -= 30
	
func process_collision(collision : KinematicCollision2D):
	if collision.collider.is_in_group("rocks"):
		damage(20)
	elif collision.collider.is_in_group("ships"):
		damage(40)
	