extends Node2D

signal HealthChanged
signal SpeedChanged

var health = 0
var speed = 0
var damage = 0

export (bool) var calculate_stats = true
export (bool) var update_weapon_anchors = false

export (NodePath) var weapon_

func update_part(_area, _part):
	for part in self.get_node(_area).get_children():
		if part.name == _part:
			part.show()
			
			if _area == "Wings":
				var left_anchor = part.get_node("WeaponAnchors/LeftPos").global_position
				var right_anchor = part.get_node("WeaponAnchors/RightPos").global_position
				$WeaponLeft.update_weapon_position(left_anchor)
				$WeaponRight.update_weapon_position(right_anchor)
		else:
			part.hide()
			
	
	if calculate_stats:
		calculate_stats()


func calculate_stats():
	health = 0
	speed = 0
	damage = 0
	
	for part_category in self.get_children():
		for part in part_category.get_children():
			var is_weapon_list = part.name == "Left" or part.name == "Right"
			
			if part.visible and not is_weapon_list:
				health += part.health_modifier
				speed += part.speed_modifier
				damage += part.damage_modifier
			
			if is_weapon_list:
				for weapon in part.get_children():
					health += weapon .health_modifier
					speed += weapon .speed_modifier
					damage += weapon .damage_modifier
	
	health = clamp(health, 0, 10)
	speed = clamp(speed, 0, 10)
	damage = clamp(damage, 0, 10)
	
	emit_signal("HealthChanged", health)
	emit_signal("SpeedChanged", speed)
	
	var stats = get_parent().get_node("UpgradeSystem/ShipInfo/Stats")
	stats.get_node("Health/MeterProgress").value = health
	stats.get_node("Speed/MeterProgress").value = speed
	stats.get_node("Damage/MeterProgress").value = damage


func wing_check():
	for wing in $Wings.get_children():
		if wing.visible:
			return true
	
	for weapon in $WeaponLeft.get_children():
		weapon.hide()
	for weapon in $WeaponRight.get_children():
		weapon.hide()
	return false


func unequip_all(_area):
	for part in get_node(_area).get_children():
		part.hide()
