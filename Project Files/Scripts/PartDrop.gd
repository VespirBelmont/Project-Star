extends "res://Scripts/CollectableCore.gd"

var dropped_part = ""

var part_settings = {
						"Jet Frame": {"Chance": 70},
						"Supersonic Frame": {"Chance": 60},
						"Star Frame": {"Chance": 40},
					}

func setup(available_parts):
	randomize()
	var chosen_part
	
	for option in available_parts:
		var part_chance = part_settings[option].Chance
		var rand_num = randi()%100
		
		if rand_num <= part_chance:
			chosen_part = option
			dropped_part = chosen_part
	
	if chosen_part == null:
		return
	
	for part in $DropNode/PartList.get_children():
		if part.name == chosen_part:
			part.show()
	
	$DropNode/AreaCollider.set_deferred("disabled", false)
	$DropNode.show()

func unlock_part(body):
	$DropNode/AreaCollider.set_deferred("disabled", true)
	var area
	
	if "Frame" in dropped_part:
		area = "Frame"
	elif "Wings" in dropped_part:
		area = "Wings"
	elif "Weapon" in dropped_part:
		area = "Weapon"
	
	var workshop_node = get_parent().get_parent().get_node("Interface/Interface/Player_%s" % body.player_id).get_node("UpgradeSystem")
	
	if area != "Weapon":
		workshop_node.unlock_part(area, dropped_part)
	else:
		workshop_node.unlock_part("WeaponRight", dropped_part)
		workshop_node.unlock_part("WeaponLeft", dropped_part)
	
	self.call_deferred("free")


