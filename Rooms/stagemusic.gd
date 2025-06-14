extends AudioStreamPlayer

var ost = {
			"town" : preload("res://Assets/Sound/Music/First Hoedown (Town Theme GAMEREADY).ogg"),
			"forest" : preload("res://Assets/Sound/Music/44 Forest (Forest Theme GAMEREADY).ogg"),
			"boss" : preload("res://Assets/Sound/Music/The Duel (Boss Theme GAMEREADY).ogg"),
			"intro" : preload("res://Assets/Sound/Music/Snake Oil (Store Theme GAMEREADY).ogg"),
			"menu" : preload("res://Assets/Sound/Music/Main Theme (GAMEREADY).ogg"),
			}
			
func play_song(music):
	if music in ost:
		stream = ost[music]
		play()
