extends "res://CharacterPuppets/Scripts/Puppets/PlatformerPuppet2D.gd"

var wall_slide_module

func _ready():
	for module in $Modules.get_children():
		if "WallSlide" in module.name:
			wall_slide_module = module

#This handles changing the state
func change_state(new_state):
	#Logic Brief:
	# > State is matched
	# > > State modifier is matched if applicable
	# > > > Behavior for that state is run
	
	match new_state: #It finds the new state being used
		"Idle":
			match state_mod: #It matches the state modifier to see if alternative behavior is to be used
				"None":
					next_anim = "Idle" #The next animation is set to the needed animation
		 
		"Move":
			match state_mod: #It matches the state modifier to see if alternative behavior is to be used
				"Walk":
					next_anim = "Walk"
				"Run":
					next_anim = "Run"
				"Sprint":
					next_anim = "Sprint"
		
		"WallSlide":
			if wall_slide_module.reset_jumps:
				jump_module.reset_jump()
			next_anim = "WallSlide"
		
		"Jump":
			next_anim = "Jump"
		
		"Fall":
			jump_module.jump_started = false
			next_anim = "Fall"
		
		"Hurt":
			next_anim = "Hurt"
		
		"Dead":
			next_anim = "Dead"
			emit_signal("death")
			set_physics_process(false)
	
	state = new_state #Then at the end the state is set to the new state


#This handles changing the state modifier [More in the Documentation Document]
func change_state_mod(new_mod):
	state_mod = new_mod #The state modifier is set to the new modifier
	change_state(state) #Then we apply changes by refreshing the state by changing the state to our current state


#This handles player inputs
func control_check():
	#These are variable shortcuts and combinations for Inputs
	var move_right = Input.is_action_pressed("Right")
	var move_left = Input.is_action_pressed("Left")
	var jump_start = Input.is_action_just_pressed("Jump") and not jump_module.jump_started and jump_module.can_jump()
	var jump_variable = Input.is_action_pressed("Jump") and jump_module.jump_started and jump_module.can_jump() and "Variable" in jump_module.name
	
	if "Instant" in move_module.name: #If it's instant movement
		move_module.velocity.x = 0
	
	if "Gradual" in move_module.name: #If the movement system is set to Instant movement
		#If the character is on the floor
		#Or if they're in the air and can slow down/stop in the air
		if is_on_floor() or not is_on_floor() and jump_module.decelerate_In_Air:
			move_module.velocity.x = 0 #Set the horizontal movement to 0 to stop the character
	
	if move_right: #If the character is moving Right
		move_module.direction.x = 1 #We set the direction to 1 since we're moving Right [Positive]
		if "Instant" in move_module.name: #If it's instant movement
			if is_on_floor(): #We check to see if the character is on the floor
				move_module.velocity.x = move_module.move_speed #We set the character movement to the instant movement speed
			else: #If the character is in the air
				move_module.velocity.x = move_module.move_speed * move_module.air_control #We set their movement to the instant movement speed times the air control value
		if "Gradual" in move_module.name: #If it's the Gradual movement
			move_module.accelerate() #Then accelerate and the function will handle the rest
	
	if move_left: #If the character is moving Left
		move_module.direction.x = -1 #We set the direction to -1 since we're moving Left [Negative]
		
		if "Instant" in move_module.name: #If it's instant movement
			if is_on_floor(): #We check to see if the character is on the floor
				move_module.velocity.x = -move_module.move_speed #We set the character movement to the instant movement speed
			else: #If the character is in the air
				move_module.velocity.x = -move_module.move_speed * move_module.air_control #We set their movement to the instant movement speed times the air control value
		if "Gradual" in move_module.name: #If the movement system is set to Gradual movement
				move_module.accelerate() #Then accelerate and the function will handle the rest
	
	#If the player isn't moving
	if not move_right and not move_left:
		#If the movement system is set for Gradual and the state is still Move
		if "Gradual" in move_module.name and state == "Move":
			#If the player is on the floor
			#Or if the player is in the air and can decelerate in the air
			if is_on_floor() or not is_on_floor() and move_module.decelerate_In_Air:
				move_module.decelerate() #Then decelerate!
		
		if state == "WallSlide" and wall_slide_module.move_to_slide: #If the player is wall sliding and needs to move to slide
			wall_slide_module.wall_slide_end() #End the wall slide since the player isn't moving
	
	#If the jump has been started but the jump button isn't being pressed; then the variable jump is over
	if jump_module.jump_started and not is_on_floor() and not jump_variable:
		jump_module.jump_released()
	
	if jump_start: #If the jump is being pressed and can launch
		jump_module.jump_launch() #Do the jump launch
	if jump_variable: #If the character is already jumping but had variable jump setup
		jump_module.jump_continue() #Continue the jump
	
	state_check() #Do a forced state check. This is used to make sure movement is interacting correctly with the stamina system.


#This handles making sure the player is in the right state
func state_check():
	if state == "Idle": #If the player is in the Idle state
		if move_module.velocity.x != 0: #If horizontal movement isn't 0
			change_state("Move") #Change the state to Move
			change_state_mod(move_module.default_move_state_mod) #And set the state modifier to the default move state modifier
	
	if state == "Move": #If the player is in the Move state
		if move_module.velocity.x == 0: #If horizontal movement is 0 [No longer moving]
			change_state("Idle") #Change the state to Idle
			change_state_mod("None") #And reset the state mode back to None
		else: #Otherwise if the horizontal movement isn't 0 [Still moving]
			use_particle("Dust") #Use the Dust particle
	
	#If the player isn't on the floor 
	#and the state isn't WallSlide
	if not is_on_floor() and not state in ["WallSlide"]:
		if state != "Fall": #If the state isn't fall
			if move_module.velocity.y > 0: #If the player is moving downward
				change_state("Fall") #Change the state to Fall
				change_state_mod("None") #And reset the state mode back to None
	
	#If the state is fall 
	#and the player is on the floor
	if state == "Fall" and is_on_floor():
		jump_module.landed() #Then the player has landed
	
	#If the player is moving 
	#and their state isn't WallSlide
	#And wall sliding is enabled
	if abs(move_module.velocity.x) > 0 and state != "WallSlide" and wall_slide_module != null: 
		#If the Wall Slide Range is detecting bodies that are within the wanted layer [More in Documentation Document]
		if wall_slide_module.get_node("WallSlideRange").get_overlapping_bodies().size() != 0:
			if state == "Fall": #If the state is in Fall since we don't want the player sliding up walls [This creates bigger gravity issues]
				#If the wall slides are limited and slide count is greater than 0
				#Or if there's no wall slide limit
				if wall_slide_module.slide_count.Current > 0 or wall_slide_module.slide_count.Current < 0:
					change_state("WallSlide") #Change the state to WallSlide
					change_state_mod("None") #And reset the state modifier
	
	if state == "WallSlide": #If the player is Wall Sliding
		#If there's no walls within range
		if wall_slide_module.get_node("WallSlideRange").get_overlapping_bodies().size() == 0:
			wall_slide_module.wall_slide_end() #End the wall slide
		
		if is_on_floor(): #If the player has hit the floor
			if wall_slide_module != null:
				wall_slide_module.wall_slide_end() #Then end the wall slide
			jump_module.landed() #And the player has also landed


