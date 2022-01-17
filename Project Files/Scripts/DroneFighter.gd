extends "res://Scripts/EnemyShipController.gd"

var player 

export (bool) var random_rotate = true
var rotation_restraints = [234, 139]

func _ready():
	player = get_parent().get_parent().get_node("Players/P1")
	
	$Modules/LookAt.set_target(player)
	
	if random_rotate:
		random_rotate()
		$Movement/RandomRotateTimer.start()

func _process(delta):
	follow_target()

func follow_target():
	$Modules/LookAt.look()
	
	rotate_weapons()

func random_rotate():
	var tw = $RotateTween
	var initial = self.rotation_degrees
	var end = rand_range(rotation_restraints[0], rotation_restraints[1])
	
	tw.interpolate_property(self, "rotation_degrees",
							initial, end, 1, 
							Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
							)
	tw.start()
	yield(tw, "tween_completed")
	$Movement/RandomRotateTimer.start()

func rotate_weapons():
	var move_dir = (player.global_position - self.global_position).normalized()
	var shoot_dir = Vector2(clamp(move_dir.x, -1, 1), clamp(move_dir.y, -1, 1))
	for weapon in $ShipManager/WeaponLeft.get_children():
		if weapon.visible:
			weapon.shoot_direction = shoot_dir
	
	for weapon in $ShipManager/WeaponRight.get_children():
		if weapon.visible:
			weapon.shoot_direction = shoot_dir


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
