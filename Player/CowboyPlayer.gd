extends CharacterBody2D
class_name CowboyPlayer

@onready var main = get_tree().get_root().get_node("Main")
@onready var hud = get_node("HUD")
@onready var bullet_display = get_node("HUD/BulletDisplay")
@onready var hp_display = get_node("HUD/HpDisplay")
@onready var dash_available = $Dash_Available
@onready var dash_timer = $Dash_Timer
@onready var reload_timer = $Reload_Timer
@onready var coin = get_node("HUD/%Money")
@onready var thunder = get_node("ThunderbirdArea")
@onready var thunder_timer = $Thunder_Timer
@onready var audio = $AudioPlayer
@onready var reload_indicator = $reload_r
@onready var r_texture = preload("res://Assets/sprites/r1.png")
@onready var r_texture2 = preload("res://Assets/sprites/r2.png")


var bullet = load("res://Player/Bullets/bullet.tscn")
var bullet_n = load("res://Player/Bullets/bullet_nessie.tscn")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#stats
#static stats carry over when changing scenes
static var ranged_dmg = 2
static var melee_dmg = 4
static var speed = 300.0
static var max_ammo = 6
var ammo = max_ammo
static var max_hp = 8
static var hp = 8
static var money = 0
static var armor = 0
static var inventory = {"darkhat": 0, "cadejo": 0, "tractor": 0}

#all dash variables
var dash_speed = 300.0
var dashing = false
var can_dash = true
var can_reload = true
var thunder_start = true

#animation variables
var sprite_dir = ""
var is_blinking = false

func _ready():
	bullet_display.update_bullets(ammo, max_ammo)
	hp_display.update_health(hp, max_hp, armor)
	$CenterPoint/Melee.damage = melee_dmg
	thunder.hide()
	reload_indicator.hide()

func _physics_process(delta):
	#takes care of player movement, gets direction from input keys
	#and looks at where the mouse position is
	var direction = Input.get_vector("left", "right", "up", "down")
	set_move_anim(direction)
	velocity = direction * speed
	if velocity != Vector2(0,0) && !audio.playing:
		var step = ["step1", "step2"]
		audio.play_sfx(step.pick_random())
	$CenterPoint.look_at(get_global_mouse_position())
	move_and_collide(velocity * delta)
	
	
	if Input.is_action_just_pressed("shoot"):
		#shoots if there is still ammo
		if ammo > 0:
			shoot()
			ammo -= 1
			#print(ammo)			
			if ammo == 0 and !is_blinking:
				reload_indicator.show()
				is_blinking = true
				start_blinking()
		else:
			#otherwise plays empty sfx
			audio.play_sfx("empty")
	
	#reloads and puts ammo back at 6
	if Input.is_action_just_pressed("reload") && can_reload:
		ammo = max_ammo;
		audio.play_sfx("reload")
		can_reload = false
		reload_timer.start()
		reload_indicator.hide()
		stop_blinking()
	
	#handles melee animation and collision
	if Input.is_action_just_pressed("melee"):
		$CenterPoint/Melee.damage = melee_dmg
		$CenterPoint/Melee.slash()
		audio.play_sfx("melee")
	
	#handles dash
	if dashing:
		if sprite_dir == "front":
			$CowboyAnim.play("front_dash")
			$DashEffect.visible = true
			$DashEffect.gravity = Vector2(0, -980)
		elif sprite_dir == "back":
			$CowboyAnim.play("back_dash")
			$DashEffect.visible = true
			$DashEffect.gravity = Vector2(0, 980)
		elif sprite_dir == "left":
			$CowboyAnim.play("side_dash")
			$CowboyAnim.flip_h = true
			$DashEffect.visible = true
			$DashEffect.gravity = Vector2(980, 0)
		elif sprite_dir == "right":
			$CowboyAnim.play("side_dash")
			$CowboyAnim.flip_h = false
			$DashEffect.visible = true
			$DashEffect.gravity = Vector2(-980, 0)
		$CowboyAnim.speed_scale = 5
		set_collision_layer_value(3, true)
		set_collision_layer_value(1, false)
		#$CowboyCollision.set_collision_layer_value(3)
	else:
		$DashEffect.visible = false
		$DashEffect.gravity = Vector2(0, 0)
		$CowboyAnim.speed_scale = 2.5
		set_collision_layer_value(3, false)
		set_collision_layer_value(1, true)
		#$CowboyCollision.set_collision_layer_value(1)

	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		dash_timer.start()
		dash_available.start()
		audio.play_sfx("dash")
		speed += dash_speed
	
	#updates hud elements
	hp_display.update_health(hp, max_hp, armor)
	coin.set_text(str(money))
	bullet_display.update_bullets(ammo, max_ammo)

func shoot():
	#makes 1 bullet right in front
	var b
	if "nessie" in inventory:
		b = bullet_n.instantiate()
	else:
		b = bullet.instantiate()
		b.damage = ranged_dmg
		b.stun_chance = inventory["darkhat"]
		b.slow = inventory["tractor"]
		b.global_position = $CenterPoint/GunPoint.global_position
		b.global_rotation = $CenterPoint/GunPoint.global_rotation - deg_to_rad(90)
		main.add_child(b)
		audio.play_sfx("fire")

func start_blinking():
	while is_blinking:
		reload_indicator.texture = r_texture
		await get_tree().create_timer(0.5).timeout
		reload_indicator.texture = r_texture2
		await get_tree().create_timer(0.5).timeout
			
func stop_blinking():
	is_blinking = false
	reload_indicator.hide()

func set_hp(health):
	var heart = hp_display.get_node("Heart1")
	for i in range(health/2):
		var h = heart.instantiate()
		h.positon.x += 50 * (1+i)

func hurt(amount, shake = 0.2):
	if armor > 0 and amount <= armor:
		armor -= amount
		if armor < 0:
			armor = 0
		$Camera2D.add_trauma(shake)
	elif armor > 0 and amount > armor:
		hp -= amount - armor
		armor -= amount
		if armor < 0:
			armor = 0
		$Camera2D.add_trauma(shake)
	else:
		hp -= amount
		$Camera2D.add_trauma(shake)
	var hurt_sound = ["hurt1", "hurt2", "hurt3"]
	audio.play_sfx(hurt_sound.pick_random())

func set_move_anim(direction):
	if direction.y < 0:
		$CowboyAnim.play("back")
		sprite_dir = "back"
	elif direction.y > 0:
		$CowboyAnim.play("front")
		sprite_dir = "front"
	elif direction.x > 0:
		$CowboyAnim.play("side")
		$CowboyAnim.flip_h = false
		sprite_dir = "right"
	elif direction.x < 0:
		$CowboyAnim.play("side")
		$CowboyAnim.flip_h = true
		sprite_dir = "left"
	elif sprite_dir == "left":
		$CowboyAnim.play("side_idle")
		$CowboyAnim.flip_h = true
	elif sprite_dir == "right":
		$CowboyAnim.play("side_idle")
		$CowboyAnim.flip_h = false
	elif sprite_dir == "back":
		$CowboyAnim.play("back_idle")
		$CowboyAnim.flip_h = false
	else:
		$CowboyAnim.play("front_idle")
		$CowboyAnim.flip_h = false

func die():
	hud.visible = false
	var die_sounds = ["die1", "die2", "die3"]
	audio.volume_db = -5
	if !audio.playing:
		audio.play_sfx(die_sounds.pick_random())
	$AnimationPlayer.play("die")

func _on_dash_available_timeout():
	can_dash = true

func _on_dash_timer_timeout():
	dashing = false
	speed -= 300

func _on_thunder_timer_timeout():
	thunder.deal_dmg()

func _on_reload_timer_timeout():
	can_reload = true

"""
old scatter shot code
var gun = 1
	if gun == 2 and Input.is_action_just_pressed("shoot"):
		if ammo > 0:
			scatter_shot()
			ammo -= 2
			print(ammo)
	
	#changes gun back and forth from revolver to shotgun
	if Input.is_action_just_pressed("gun_change"):
		gun += 1
		if gun > 2:
			gun = 1
	
	func scatter_shot():
	#makes a scatter shot with 3 bullets in front
	var a = bullet.instantiate()
	var b = bullet.instantiate()
	var c = bullet.instantiate()
	a.damage = damage-3
	a.global_position = $Marker2D.global_position
	a.global_rotation = $Marker2D.global_rotation - deg_to_rad(90)
	main.add_child(a)
	b.damage = damage-3
	b.global_position = $Marker2D.global_position
	b.global_rotation = $Marker2D.global_rotation - deg_to_rad(75)
	main.add_child(b)
	c.damage = damage-3
	c.global_position = $Marker2D.global_position
	c.global_rotation = $Marker2D.global_rotation - deg_to_rad(105)
	main.add_child(c)
"""
