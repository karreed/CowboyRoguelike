extends HBoxContainer

func update_bullets(ammo, max_ammo):
	if max_ammo == 6:
		$BulletHUD.frame = ammo
		$BulletHUD2.visible = false
	elif max_ammo == 12:
		$BulletHUD2.visible = true
		$BulletHUD2.frame = ammo-6
		$BulletHUD.frame = ammo
