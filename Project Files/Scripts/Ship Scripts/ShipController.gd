extends "res://CharacterPuppets/Scripts/Puppets/TopDownPuppet2D.gd"

var xp = 0 #XP is gained from multiple actions and contributes to leveling up the ship

var level = 1 #Level is how far along you are in ship development
#Level Documentation
#Level 1-5 is planetary travel
#Level 6+ will be space travel if I decide to make it that far later on

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

