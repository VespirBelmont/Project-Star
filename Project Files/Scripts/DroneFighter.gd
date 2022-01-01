extends "res://Scripts/EnemyShipController.gd"


#This handles flipping horizontal enemies
func check_horizontal_direction():
	yield(get_tree().create_timer(1), "timeout") #A little wait to make sure everything is ready
	
	#This gets the middle position of the game
	var middle_pos = get_parent().get_node("MiddlePos")
	
	#If the enemy position is to the right of the middle
	if global_position.x > middle_pos.global_position.x:
		scale.y *= -1 #The enemy is flipped to face the other direction
	
	#Then we go through each weapon to find the one we also need to flip
		for weapon in $ShipManager/WeaponLeft.get_children():
			if weapon.visible:
				weapon.shoot_direction.x *= -1
		for weapon in $ShipManager/WeaponRight.get_children():
			if weapon.visible:
				weapon.shoot_direction.x *= -1
