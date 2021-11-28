extends "res://Scripts/Ship Scripts/ShipController.gd"

export (int) var player_id = 1

func _ready():
	can_move = true

func _physics_process(delta):
	move_module.apply_gravity(delta)
	control_check()
	move_module.move()



func control_check():
	var move_right = Input.is_action_pressed("MoveRight_%s" % player_id) and can_move and $VisualManager.wing_check()
	var move_left = Input.is_action_pressed("MoveLeft_%s" % player_id) and can_move and $VisualManager.wing_check()
	var accelerate = Input.is_action_pressed("Accelerate_%s" % player_id) and can_move and $VisualManager.wing_check()
	var brake = Input.is_action_pressed("Brake_%s" % player_id) and can_move and $VisualManager.wing_check()
	
	var shoot_left = Input.is_action_pressed("ShootLeft_%s" % player_id)
	var shoot_right = Input.is_action_pressed("ShootRight_%s" % player_id)
	
	move_module.velocity = Vector2()
	
	if move_right:
		move_module.velocity.x = move_module.move_speed * (move_module.move_speed_mod * 1)
	if move_left:
		move_module.velocity.x = -move_module.move_speed * (move_module.move_speed_mod * 1)
	
	if accelerate:
		move_module.velocity.y = -move_module.accelerate_speed * (move_module.move_speed_mod * 1)
		
		if not $Audio/Accelerate.playing:
			$Audio/Accelerate.play()
	if not accelerate:
		if $Audio/Accelerate.playing:
			$Audio/Accelerate.stop()
	
	if brake:
		move_module.velocity.y = move_module.brake_speed * (move_module.move_speed_mod * 1.2)
		
		if not $Audio/Brake.playing:
			$Audio/Brake.play()
	
	if $VisualManager.wing_check() and move_module.velocity.y < 0:
		move_module.velocity.y -= move_module.auto_move_speed
	
	if shoot_left:
		for side_weapon in $VisualManager/WeaponLeft.get_children():
			if side_weapon.visible:
				side_weapon.shoot()
	
	if shoot_right:
		for side_weapon in $VisualManager/WeaponRight.get_children():
			if side_weapon.visible:
				side_weapon.shoot()



