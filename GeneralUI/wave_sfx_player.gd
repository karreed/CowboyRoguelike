extends AudioStreamPlayer

var sounds = {
			"shop_summon": preload("res://Assets/Sound/General Sound WAVs/Store Summon.wav"),
			"shop_leave" : preload("res://Assets/Sound/General Sound WAVs/Store Leaves.wav"),
			"new_wave" : preload("res://Assets/Sound/General Sound WAVs/New Wave.wav"),
			"kill1" : preload("res://Assets/Sound/General Sound WAVs/Player Kill.wav"),
			"kill2" : preload("res://Assets/Sound/General Sound WAVs/Player Kill 2.wav"),
			"kill3" : preload("res://Assets/Sound/General Sound WAVs/Player Kill 3.wav"),
			"kill4" : preload("res://Assets/Sound/General Sound WAVs/Player Kill 4.wav")
			}

func play_sfx(sound):
	if sound in sounds:
		stream = sounds[sound]
		play()
