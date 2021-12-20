extends "res://CharacterPuppets/Scripts/Puppets/TopDownPuppet2D.gd"

var can_move : bool = false

export var part_setup = {
						 "Frame": "",
						 "Wings": "",
						 "WeaponRight": "",
						 "WeaponLeft": ""
						}

func _ready():
	
	if part_setup["Frame"] != "":
		$ShipManager.update_part("Frame", part_setup["Frame"])
	
	if part_setup["Wings"] != "":
		$ShipManager.update_part("Wings", part_setup["Wings"])
	
	if part_setup["WeaponRight"] != "":
		$ShipManager.update_part("WeaponRight", part_setup["WeaponRight"])
	
	if part_setup["WeaponLeft"] != "":
		$ShipManager.update_part("WeaponLeft", part_setup["WeaponLeft"])


func shoot(_side):
	if _side == "Left":
		for side_weapon in $ShipManager/WeaponLeft.get_children():
			if side_weapon.visible:
				side_weapon.shoot()
	
	if _side == "Right":
		for side_weapon in $ShipManager/WeaponRight.get_children():
			if side_weapon.visible:
				side_weapon.shoot()


