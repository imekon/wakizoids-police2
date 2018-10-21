extends Node2D

onready var rock1 = load("res://scenes/Rock1.tscn")
onready var rock2 = load("res://scenes/Rock2.tscn")
onready var rock3 = load("res://scenes/Rock3.tscn")
onready var rock4 = load("res://scenes/Rock4.tscn")
onready var rock5 = load("res://scenes/Rock5.tscn")
onready var rock6 = load("res://scenes/Rock6.tscn")

onready var alien1 = load("res://scenes/Alien1.tscn")
onready var alien2 = load("res://scenes/Alien2.tscn")
onready var alien3 = load("res://scenes/Alien3.tscn")
onready var alien4 = load("res://scenes/Alien4.tscn")

onready var planet1 = load("res://scenes/Planet1.tscn")
onready var planet2 = load("res://scenes/Planet2.tscn")
onready var planet3 = load("res://scenes/Planet3.tscn")
onready var planet4 = load("res://scenes/Planet4.tscn")

onready var mining_ship = load("res://scenes/MiningShip.tscn")

onready var player = $PlayerShip
onready var scoreLabel = $HUD/ScoreLabel
onready var scanner = $HUD/Scanner

func _ready():
	randomize()
	generate_rocks()
	generate_mining_ships()
	generate_alien_ships()
	generate_planets()
	
func _process(delta):
	scoreLabel.text = "Score: " + str(player.score)
	if Input.is_action_just_pressed("ui_long_range_scanner"):
		scanner.set_long_range_scanner()
	elif Input.is_action_just_pressed("ui_medium_range_scanner"):
		scanner.set_medium_range_scanner()
	elif Input.is_action_just_pressed("ui_short_range_scanner"):
		scanner.set_short_range_scanner()
	
func random_range(value):
	return randi() % value - value / 2
	
func generate_rocks():
	for i in range(20):
		generate_rock(rock1, random_range(65536), random_range(65536))
		generate_rock(rock2, random_range(65536), random_range(65536))
		generate_rock(rock3, random_range(65536), random_range(65536))
		generate_rock(rock4, random_range(65536), random_range(65536))
		generate_rock(rock5, random_range(65536), random_range(65536))
		generate_rock(rock6, random_range(65536), random_range(65536))

func generate_mining_ships():
	# test mining ship right next to player
	# generate_mining_ship(mining_ship, 100, 100, "TST001")
	for i in range(100):
		generate_mining_ship(mining_ship, random_range(65536), random_range(65536), "MNR" + str(i + 100))
		
func generate_alien_ships():
	for i in range(4):
		generate_alien_ship(alien1, random_range(65536), random_range(65536))
		generate_alien_ship(alien2, random_range(65536), random_range(65536))
		generate_alien_ship(alien3, random_range(65536), random_range(65536))
		generate_alien_ship(alien4, random_range(65536), random_range(65536))
		
func generate_planets():
	# generate_planet(planet1, 0, 0)
	generate_planet(planet1, random_range(65536), random_range(65536))
	generate_planet(planet2, random_range(65536), random_range(65536))
	generate_planet(planet3, random_range(65536), random_range(65536))
	generate_planet(planet4, random_range(65536), random_range(65536))
	
func generate_rock(resource, x, y):
	var rock = resource.instance()
	rock.position = Vector2(x, y)
	add_child(rock)
	
func generate_mining_ship(resource, x, y, reg):
	var ship = resource.instance()
	add_child(ship)
	ship.position = Vector2(x, y)
	ship.set_registration(reg)

func generate_alien_ship(resource, x, y):
	var ship = resource.instance()
	add_child(ship)
	ship.position = Vector2(x, y)

func generate_planet(resource, x, y):
	var planet = resource.instance()
	add_child(planet)
	planet.position = Vector2(x, y)
