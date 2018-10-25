extends KinematicBody2D

const MOVEMENT = 100.0

enum STATUS { DRIFTING, TARGETING, TURNING, MOVING, SHOOTING }

var status
var thrust
var targeting_helper
var shields

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
			
func damage(amount):
	shields -= amount
	if shields < 0:
		queue_free()
	status = TARGETING
	
func process_drifting(delta):
	thrust = MOVEMENT * delta
	var rot = rotation_degrees - 90
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
	pass
	