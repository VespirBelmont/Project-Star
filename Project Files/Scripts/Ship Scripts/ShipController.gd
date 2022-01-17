extends "res://CharacterPuppets/Scripts/Puppets/TopDownPuppet2D.gd"

var can_move : bool = false
var can_control : bool = true

export var parts_equipped = {
						 "Frame": "",
						 "Wings": "",
						 "WeaponRight": "",
						 "WeaponLeft": ""
						}

func _ready():
	
	if parts_equipped["Frame"] != "":
		$ShipManager.update_part("Frame", parts_equipped["Frame"])
	
	if parts_equipped["Wings"] != "":
		$ShipManager.update_part("Wings", parts_equipped["Wings"])
	
	if parts_equipped["WeaponRight"] != "":
		$ShipManager.update_part("WeaponRight", parts_equipped["WeaponRight"])
	
	if parts_equipped["WeaponLeft"] != "":
		$ShipManager.update_part("WeaponLeft", parts_equipped["WeaponLeft"])


func update_parts(_area, _part):
	parts_equipped[_area] = _part

func shoot(_side):
	if _side == "Left":
		for side_weapon in $ShipManager/WeaponLeft.get_children():
			if side_weapon.visible:
				side_weapon.shoot()
	
	if _side == "Right":
		for side_weapon in $ShipManager/WeaponRight.get_children():
			if side_weapon.visible:
				side_weapon.shoot()

func destroy():
	self.call_deferred("free")

func shock_check():
	for se in $StatusEffects.get_children():
		if "Shock" in se.name:
			return true
	
	return false
