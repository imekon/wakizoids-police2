extends KinematicBody2D

const MOVEMENT = 200.0

enum STATUS { DRIFTING, TARGETING, TURNING, MOVING, TURNING_TO_SHOOT, SHOOTING }

onready var bullet_resource = load("res://scenes/Bullet.tscn")

onready var firing_position = $FiringPosition

var status
var thrust
var targeting_helper
var shields
var firing_count
var last_fired

func _ready():
	var target_helper_resource = load("res://scripts/TargetingHelper.gd")
	targeting_helper = target_helper_resource.new()
	shields = 100
	var angle = randf() * 360
	rotate(deg2rad(angle))
	status = DRIFTING

func _physics_process(delta):
	match status:
		DRIFTING:
			process_drifting(delta)
		TARGETING:
			process_targeting(delta)
		TURNING:
			process_turning(delta)
		MOVING:
			process_moving(delta)
		TURNING_TO_SHOOT:
			process_turning_to_shoot(delta)
		SHOOTING:
			process_shooting(delta)
			
func damage(amount):
	shields -= amount
	if shields < 0:
		queue_free()
	status = TARGETING
	
func process_drifting(delta):
	thrust = MOVEMENT * delta
	var rot = rotation_degrees
	var direction = Vector2(thrust, 0).rotated(deg2rad(rot))
	var collide = move_and_collide(direction)
	if shields < 100:
		shields += 1
		
func process_targeting(delta):
	var ships = get_tree().get_nodes_in_group("mining_ship")
	var closest_distance = 999999
	var closest_ship = null
	for ship in ships:
		var distance = global_position.distance_to(ship.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_ship = ship
	
	if closest_ship != null:
		targeting_helper.set_target(closest_ship)
		targeting_helper.plot_course_to_target(global_position)
		status = TURNING

func process_turning(delta):
	if !targeting_helper.plot_course_to_target(global_position):
		return
		
	var angle_delta
	
	if targeting_helper.target_angle > rotation_degrees:
		angle_delta = 1
	else:
		angle_delta = -1
		
	if abs(rotation_degrees - targeting_helper.target_angle) > 1:
		rotate(deg2rad(angle_delta))
	else:
		status = MOVING

func process_moving(delta):
	if !targeting_helper.target.get_ref():
		status = DRIFTING
		return
		
	thrust = MOVEMENT * delta
	var rot = rotation_degrees
	var direction = Vector2(thrust, 0).rotated(deg2rad(rot))
	var collide = move_and_collide(direction)
	if shields < 100:
		shields += 1

	var target_position = targeting_helper.target.get_ref().global_position
	var distance = global_position.distance_to(target_position)
	if distance < 500:
		status = TURNING_TO_SHOOT
		firing_count = 0
		
func process_turning_to_shoot(delta):
	if !targeting_helper.plot_course_to_target(global_position):
		return
		
	var angle_delta
	
	if targeting_helper.target_angle > rotation_degrees:
		angle_delta = 1
	else:
		angle_delta = -1
		
	if abs(rotation_degrees - targeting_helper.target_angle) > 1:
		rotate(deg2rad(angle_delta))
	else:
		last_fired = OS.get_ticks_msec()
		status = SHOOTING

func process_shooting(delta):
	var now = OS.get_ticks_msec()
	if now - last_fired > 100:
		var bullet = bullet_resource.instance()
		bullet.set_owner(get_parent())
		bullet.position = firing_position.global_position
		bullet.rotate(rotation)
		get_parent().add_child(bullet)
		last_fired = now
		firing_count += 1

	if firing_count > 5:
		status = DRIFTING
		targeting_helper.clear()