extends "res://Scripts/EnemyShipController.gd"

func _ready():
	pass


func check_horizontal_direction():
	print("Parent: ", get_parent().name)
	yield(get_tree().create_timer(1), "timeout")
	var middle_pos = get_parent().get_node("MiddlePos")
	
	print(global_position.x)
	if global_position.x > middle_pos.global_position.x:
		scale.y = 1
	
		for weapon in $ShipManager/WeaponLeft.get_children():
			if weapon.visible:
				weapon.shoot_direction.x = -1
		for weapon in $ShipManager/WeaponRight.get_children():
			if weapon.visible:
				weapon.shoot_direction.x = -1
