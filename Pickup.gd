extends Area2D

func _on_body_entered(body):
	if body.name == "CowboyPlayer":
		body.money += 1
		body.audio.play_sfx("coin")
		queue_free()

func _on_despawn_timer_timeout():
	queue_free()
