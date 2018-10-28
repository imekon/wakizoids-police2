extends Node2D

const MOVEMENT = 200.0
const SLEEP_TIME = 30000

enum AI_STATUS { IDLE, SLEEPING, TURNING, MOVING, TURN_TO_SHOOT, SHOOTING }
enum ROGUE_STATUS { HONEST, ROGUE_HIDDEN, ROGUE }
enum SWARM_STATUS { NONE, COPS, MINERS, ALIENS }

onready var node2d = $Node2D
onready var registration_label = $Node2D/Registration
onready var body = $KinematicBody2D
onready var firing_position = $KinematicBody2D/FiringPosition

onready var bullet_resource = load("res://scenes/Bullet.tscn")

var ai_status : int
var rogue_status : int
var swarm_status : int
var registration : String
var credits : int
var shields : int
var energy : float
var thrust : float
var targeting_helper
var last_distance : float
var last_fired = 0
var firing_count : int

func _ready():
	var target_helper_resource = load("res://scripts/TargetingHelper.gd")
	targeting_helper = target_helper_resource.new()
	ai_status = IDLE
	rogue_status = HONEST
	swarm_status = NONE
	credits = 0
	shields = 100
	energy = 100
	thrust = 0
	var angle = randf() * 360
	last_distance = 0
	body.rotate(deg2rad(angle))

func _physics_process(delta):
	var miner_position = body.global_position
	
	var status_text = "NOT SET"

	match ai_status:
		IDLE:
			process_idle(delta, miner_position)
			status_text = registration + ": IDLE"
		SLEEPING:
			process_sleep(delta)
			status_text = registration + ": SLEEPING"
		TURNING:
			process_turning(delta, miner_position)
			status_text = registration + ": MOVING"
		MOVING:
			process_moving(delta, miner_position)
			status_text = registration + ": MOVING"
		TURN_TO_SHOOT:
			process_turn_to_shoot(delta, miner_position)
			status_text = registration + ": SHOOTING"
		SHOOTING:
			process_shooting(delta, miner_position)
			status_text = registration + ": SHOOTING"
			
	registration_label.text = status_text + ": CREDITS %d" % credits

func set_registration(text : String):
	registration = text
	registration_label.text = text
	
func add_credit(amount):
	credits += amount
	
func set_swarm_target(swarm):
	pass

func process_idle(delta, miner_position):
	targeting_helper.clear()
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
		
	targeting_helper.set_target(closest_rock)
	targeting_helper.plot_course_to_target(miner_position)
	
	ai_status = TURNING
	
func process_sleep(delta):
	var now = OS.get_ticks_msec()
	if now - last_fired > SLEEP_TIME:
		ai_status = IDLE

func process_turning(delta, miner_position):
	if !targeting_helper.plot_course_to_target(miner_position):
		return
		
	var angle = body.rotation_degrees
	var angle_delta
	
	if targeting_helper.target_angle > angle:
		angle_delta = 1
	else:
		angle_delta = -1
		
	if abs(angle - targeting_helper.target_angle) > 1:
		body.rotate(deg2rad(angle_delta))
	else:
		ai_status = MOVING

func process_moving(delta, miner_position):
	if !targeting_helper.plot_course_to_target(miner_position):
		return
		
	thrust = MOVEMENT * delta
	body.rotation_degrees = targeting_helper.target_angle
	var direction = Vector2(thrust, 0).rotated(deg2rad(targeting_helper.target_angle))
	var collide = body.move_and_collide(direction)
	node2d.position = body.position
	
	var distance = miner_position.distance_to(targeting_helper.target_position)
	last_distance = distance
	if distance < 500:
		firing_count = 0
		ai_status = TURN_TO_SHOOT

func process_turn_to_shoot(delta, miner_position):
	if !targeting_helper.plot_course_to_target(miner_position):
		return

	var angle = body.rotation_degrees
	var angle_delta
	
	if targeting_helper.target_angle > angle:
		angle_delta = 1
	else:
		angle_delta = -1
		
	var offset = abs(angle - targeting_helper.target_angle)
		
	if offset > 1:
		body.rotate(deg2rad(angle_delta))
	else:
		firing_count = 0
		ai_status = SHOOTING

func process_shooting(delta, miner_position):
	var now = OS.get_ticks_msec()
	if now - last_fired > 100:
		var bullet = bullet_resource.instance()
		bullet.set_owner(self)
		bullet.position = firing_position.global_position
		bullet.rotate(body.rotation)
		get_parent().add_child(bullet)
		last_fired = now
		firing_count += 1

	if firing_count > 5:
		ai_status = SLEEPING
		targeting_helper.clear()