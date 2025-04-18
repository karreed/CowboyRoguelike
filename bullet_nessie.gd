extends Area2D

var speed = 750
var damage : int
var stun_chance = 0
var slow = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#makes the bullt go straight in front
	var velocity = Vector2(0, speed).rotated(rotation)
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		#if it hits the player or spawns inside the player
		#just skips
		pass
	elif body.is_in_group("enemy"):
		print("detected enemy")
		deal_dmg(body)
		body.hit_by_player = true
	elif body.is_in_group("boss"):
		body.take_damage()
	else:
		#if it hits anything else, disappears
		queue_free()

func deal_dmg(body):
	body.hp -= damage
	if stun_chance > 0 && randi_range(0, 100) <= 5 * stun_chance:
		body.stun += 1
	if slow:
		body.slow += slow
