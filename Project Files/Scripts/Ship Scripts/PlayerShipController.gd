extends "res://Scripts/Ship Scripts/ShipController.gd"

export (int) var player_id = 1 #This is the player ID telling which player is which


#This handles the node initialization
func _ready():
	can_move = true #Allows the player to move


#This runs every frame
func _physics_process(delta):
	control_check() #This checks for control inputs
	move_module.move() #This moves the player
	
	PlayerInfo.player_pos = self.global_position


#This handles all control inputs
func control_check():
	if shock_check():
		var rand_num = randi()%10
		
		if rand_num > 4 and can_control:
			$FX/Shocked/Anim.play("Shocked")
			$FX/Shocked.show()
			lose_control(0.5)
			return
	
	if not can_control: return
	
	#--Variable Shortcuts--#
	var move_requirements = can_move and $ShipManager.wing_check() #A shortcut for the movement requirements
	
	var move_right = Input.is_action_pressed("MoveRight_%s" % player_id) and move_requirements
	var move_left = Input.is_action_pressed("MoveLeft_%s" % player_id) and move_requirements
	var accelerate = Input.is_action_pressed("Accelerate_%s" % player_id) and move_requirements
	var brake = Input.is_action_pressed("Brake_%s" % player_id) and move_requirements
	
	var shoot_left = Input.is_action_pressed("ShootLeft_%s" % player_id)
	var shoot_right = Input.is_action_pressed("ShootRight_%s" % player_id)
	#---------------#
	
	
	#MOVEMENT CODE#
	move_module.velocity = Vector2() #Sets velocity back to 0 every tick
	
	
	#This checks for Right and Left movement inputs
	if move_right:
		#If there is movement, we take the move speed of our ship and multiply it by the move speed modifier
		move_module.velocity.x = move_module.move_speed * (move_module.move_speed_mod)
	
	if move_left:
		move_module.velocity.x = -move_module.move_speed * (move_module.move_speed_mod)
	
	#This checks to see if the player is Accelerating
	if accelerate:
		move_module.velocity.y = -move_module.accelerate_speed * (move_module.move_speed_mod)
		
		if not $Audio/Accelerate.playing: #If the audio for accelerating isn't playing
			$Audio/Accelerate.play() #Then it will play
	
	#This checks to see if the player isn't Accelerating (Forward)
	if not accelerate:
		if $Audio/Accelerate.playing: #If the accelerating audio is playing
			$Audio/Accelerate.stop() #Then the audio stops
	
	#This checks to see if the player is Braking (Backward)
	if brake:
		move_module.velocity.y = move_module.brake_speed * (move_module.move_speed_mod * 1.2)
		
		if not $Audio/Brake.playing: #If the audio for braking isn't playing
			$Audio/Brake.play() #Then the audio will play
	
	#This checks to see if the ship has wings and if the ship can move
	if move_requirements:
		#If there is wings then the ship can move forward
		move_module.velocity.y -= move_module.auto_move_speed
	#------------#
	
	#COMBAT CODE#
	
	#This checks to see if the player is shooting from the left side
	if shoot_left:
		#Checks through the weapons to see which one is equipped
		for side_weapon in $ShipManager/WeaponLeft.get_children():
			if side_weapon.visible: #The weapon being visible means it's equipped
				side_weapon.shoot() #Then the weapon will shoot
	
	#This checks to see if the player is shooting from the right side
	if shoot_right:
		#Checks through the weapons to see which one is equipped
		for side_weapon in $ShipManager/WeaponRight.get_children():
			if side_weapon.visible: #The weapon being visible means it's equipped
				side_weapon.shoot() #Then the weapon will shoot
	#------------#


func lose_control(duration):
	can_control = false
	
	yield(get_tree().create_timer(duration), "timeout")
	$FX/Shocked.hide()
	
	can_control = true


