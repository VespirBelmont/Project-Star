extends "res://Scripts/StatusEffect.gd"

export (Dictionary) var slow_duration = {
											"Weak": 1,
											"Mild": 1,
											"Strong": 1,
											"Extreme": 1,
										}

export (PackedScene) var ice_tscn


func slow_ship():
	root.get_node("Modules").get_node("InstantMoveSystem").slow(slow_duration[severity])
	
	change_color("ToEffect")
	
	$SlowDurationTimer.wait_time = slow_duration[severity]
	$SlowDurationTimer.start()

func create_weapon_ice():
	var ship_manager = root.get_node("ShipManager")
	var weapon_right_list = ship_manager.get_node("WeaponRight")
	var weapon_left_list = ship_manager.get_node("WeaponLeft")
	
	var weapon_right = weapon_right_list.get_node(root.parts_equipped["WeaponRight"])
	var weapon_left = weapon_left_list.get_node(root.parts_equipped["WeaponLeft"])
	
	var weapons = [weapon_right, weapon_left]
	for weapon in weapons:
		if weapon != null:
			var parent = weapon.get_node("ProjectileSpawnPos")
			var new_ice = ice_tscn.instance()
			
			parent.add_child(new_ice)
			new_ice.global_position = parent.global_position


