extends Node2D

const MOVEMENT = 200.0
const SLEEP_TIME = 30000

enum AI_STATUS { IDLE, SLEEPING, TURNING, MOVING, TURN_TO_SHOOT, SHOOTING }
enum ROGUE_STATUS { HONEST, ROGUE_HIDDEN, ROGUE }

onready var node2d = $Node2D
onready var registration_label = $Node2D/Registration
onready var body = $KinematicBody2D
onready var firing_position = $KinematicBody2D/FiringPosition

onready var bullet_resource = load("res://scenes/Bullet.tscn")

var ai_status
var rogue_status
var registration
var credits
var shields
var energy
var thrust
# var targeting_helper
var target
var target_position
var target_angle
var target_angle_offset
var target_distance
var last_distance
var last_fired = 0
var firing_count

func _ready():
	# var target_helper_resource = load("res://scripts/TargetingHelper.gd")
	# targeting_helper = target_helper_resource.new()
	ai_status = IDLE
	rogue_status = HONEST
	credits = 0
	shields = 100
	energy = 100
	thrust = 0
	target = null
	var angle = randf() * 360
	last_distance = 0
	body.rotate(deg2rad(angle))

func _physics_process(delta):
	var miner_position = body.global_position

	match ai_status:
		IDLE:
			process_idle(delta, miner_position)
			registration_label.text = registration + ": IDLE"
		SLEEPING:
			process_sleep(delta)
			registration_label.text = registration + ": SLEEPING"
		TURNING:
			process_turning(delta, miner_position)
			registration_label.text = registration + ": TURNING"
		MOVING:
			process_moving(delta, miner_position)
			registration_label.text = registration + ": MOVING > %1.2f" % last_distance
		TURN_TO_SHOOT:
			process_turn_to_shoot(delta, miner_position)
			registration_label.text = registration + ": TURN TO SHOOT"
		SHOOTING:
			process_shooting(delta, miner_position)
			registration_label.text = registration + ": SHOOTING"

func set_registration(text):
	registration = text
	registration_label.text = text

func process_idle(delta, miner_position):
	target = null
	var rocks = get_tree().get_nodes_in_group("rocks")
	var closest_rock = null
	var closest_dist = 1000000
	var closest_position
	for rock in rocks:
		var pos = rock.global_position
		var dist = miner_position.distance_to(pos)
		if dist < closest_dist && !rock.is_queued_for_deletion():
			closest_dist = dist
			closest_rock = rock
			closest_position = pos
				
	if closest_rock == null:
		ai_status = SLEEPING
		return
		
	target = weakref(closest_rock)
	target_position = closest_position
	target_angle = rad2deg(target_position.angle_to_point(miner_position))
	
	ai_status = TURNING
	
func plot_course_to_target(miner_position):
	if target == null:
		last_fired = OS.get_ticks_msec()
		ai_status = null
		return false
	
	if !target.get_ref():
		last_fired = OS.get_ticks_msec()
		ai_status = null
		target = null
		return false
		
	target_position = target.get_ref().global_position
	target_angle = rad2deg(target_position.angle_to_point(miner_position))
	return true

func process_sleep(delta):
	var now = OS.get_ticks_msec()
	if now - last_fired > SLEEP_TIME:
		ai_status = IDLE

func process_turning(delta, miner_position):
	if !plot_course_to_target(miner_position):
		return
		
	var angle = body.rotation_degrees
	var angle_delta
	
	if target_angle > angle:
		angle_delta = 1
	else:
		angle_delta = -1
		
	if abs(angle - target_angle) > 1:
		body.rotate(deg2rad(angle_delta))
	else:
		ai_status = MOVING

func process_moving(delta, miner_position):
	if !plot_course_to_target(miner_position):
		return
		
	thrust = MOVEMENT * delta
	body.rotation_degrees = target_angle
	var direction = Vector2(thrust, 0).rotated(deg2rad(target_angle))
	var collide = body.move_and_collide(direction)
	node2d.position = body.position
	
	target_distance = miner_position.distance_to(target_position)
	last_distance = target_distance
	if target_distance < 500:
		firing_count = 0
		ai_status = TURN_TO_SHOOT

func process_turn_to_shoot(delta, miner_position):
	if !plot_course_to_target(miner_position):
		return

	var angle = body.rotation_degrees
	var angle_delta
	
	if target_angle > angle:
		angle_delta = 1
	else:
		angle_delta = -1
		
	target_angle_offset = abs(angle - target_angle)
		
	if target_angle_offset > 1:
		body.rotate(deg2rad(angle_delta))
	else:
		firing_count = 0
		ai_status = SHOOTING

func process_shooting(delta, miner_position):
	var now = OS.get_ticks_msec()
	if now - last_fired > 100:
		var bullet = bullet_resource.instance()
		bullet.set_owner(get_parent())
		bullet.position = firing_position.global_position
		bullet.rotate(body.rotation)
		get_parent().add_child(bullet)
		last_fired = now
		firing_count += 1

	if firing_count > 5:
		ai_status = SLEEPING
		target = null