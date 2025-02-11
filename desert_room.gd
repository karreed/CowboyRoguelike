extends Node2D

var rng = RandomNumberGenerator.new()
@onready var tilemap = $DesertTile
@onready var player = $CowboyPlayer
@onready var enemies = [load("res://enemy.tscn"), load("res://goat_head.tscn")]
@onready var wave_timer = $WaveTimer
@onready var shop_spawn = load("res://shop.tscn")

#ids to get each tile from the tilemap
var tile_ids = [Vector2i(0, 0), Vector2i(1,0), #base tiles
				Vector2i(0,1), Vector2i(1,1), Vector2i(0,2)] #vegetation

#array with duplicates so that the empty tiles are more likely
var tileset_prob = [
				Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0),
				Vector2i(1,0), Vector2i(1,0), Vector2i(1,0), Vector2i(1,0),
				Vector2i(0,1),
				Vector2i(1,1),
				Vector2i(0,2)]

#how many rows and columns to generate
#can be adjusted to get bigger rooms
var room_height = 25
var room_width = 25

var wave = 1
var spawn_points = []
var difficulty = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	start_up()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#if the player runs out of health, goes to the gameover screen
	if player.hp <= 0:
		#get_tree().change_scene_to_file("res://game_over.tscn")
		pass
	
	if Input.is_action_just_pressed("ui_accept"):
		clean_up()
		start_up()

func create_room(width, height, padding = 6):
	#nested for loops to get i rows and j columns
	#padding is so that around the room there's still tiles and doesn't stop suddenly
	for i in range(-padding, height+padding):
		for j in range(-padding*2, width+(padding*2)):
			#0 is the layer, Vector2i(j,i) is the coordinate the tile will be placed at
			#0 is what tileset it is
			#tileset_prob is the coordinates for the actual tile from the tileset
			tilemap.set_cell(0, Vector2i(j,i), 0, tileset_prob.pick_random())
			
			if i == 5 || i == height - 5 || j == 5 || j == width - 5:
				if i > 0 && i < height && j > 0 && j < width:
					spawn_points.append(Vector2i(j, i))
	
	#creates invisible wall around the edge of the room
	for i in range(height+1):
		tilemap.set_cell(1, Vector2i(-1, i), 1, Vector2i(0,0))
		tilemap.set_cell(1, Vector2i(width+1, i), 1, Vector2i(0,0))
	for i in range(width+1):
		tilemap.set_cell(1, Vector2i(i,-1), 1, Vector2i(0,0))
		tilemap.set_cell(1, Vector2i(i, height+1), 1, Vector2i(0,0))

func spawn_enemy(spawn_pos):
	#create a new enemy instance and set the position
	var e = enemies.pick_random().instantiate()
	e.position = spawn_pos
	add_child(e)

func start_up():
	create_room(room_width, room_height)
	player.position = tilemap.map_to_local(Vector2i(room_width/2, room_height/2))
	#starts wave timer and makes the first wave spawn earlier
	wave_timer.start()
	wave_timer.wait_time = 20

func clean_up():
	tilemap.clear()
	var all_children = get_children()
	for child in all_children:
		if child.is_in_group("enemy"):
			child.queue_free()

func spawn_wave(difficulty):
	var spawn_array = spawn_points
	for i in range(randi_range(difficulty, difficulty+3)):
		#picks a random point from the possible spawn points
		#spawns an enemy and then pops the value so there isn't duplicates
		#print(spawn_array)
		var spawn_pos = spawn_array.pop_at(randi_range(0, spawn_array.size()))
		#print(spawn_pos)
		#print(spawn_array)
		spawn_enemy(tilemap.map_to_local(spawn_pos))

func _on_wave_timer_timeout():
	print("wave ", wave)
	#if wave == 1:
	if wave % 5 == 0:
		#function spawn shop
		var shop = shop_spawn.instantiate()
		shop.position = player.position
		shop.add_to_group("shop")
		add_child(shop)
		print("shop spawn")
		difficulty += 3
	elif wave + 1 % 5 == 0:
		var shop = get_node("Shop")
		shop.queue_free()
	else:
		print("enemy spawn")
		spawn_wave(difficulty)
	wave += 1
