extends Node

onready var controller = get_parent().get_parent()
onready var move_module = controller.move_module

signal Jumped
signal Landed

export (int) var jump_count_default #This is how many jumps the character can do before landing
onready var jump_count_left = jump_count_default #This is how many jumps the character has left
export (float) var force_intial #This is how much the character will jump up for the initial jump and Classic jump
export (float) var force = 10 #This is the amount the character will move up while the jump button is held
export var duration = {"Default": 0, "Left": 0} #This is the duration the character can jump for

var jump_started = false #This tells the character if they've already jumped or not; especially useful for variable jump



func _ready():
	reset_duration()
	for module in controller.get_node("Modules").get_children():
		if "Move" in module.name:
			move_module = module


#This handles the initial jump and classic jump for the character
func jump_launch():
	jump_started = true #The jump has now been started
	#The initial jump sets the Y velocity value to the jump force of the launch jump [Negates it since Up in 2D is Negative]
	move_module.velocity.y = -force_intial
	
#	if controller.state == "WallSlide": #If the character is wall sliding
#		move_module.velocity.y = -wall_jump_settings.JumpForce #Set the launch force to the wall jump setting instead of the character launch force
#		move_module.velocity.x = wall_jump_settings.PushOff * (direction.x * -1) #Do a walljump which means moving horizontally
	
	emit_signal("Jumped") #Emit the signal of Jumped


#This handles continuing the Variable jump
func jump_continue():
	#Modify the jump duration by subtracting by a value [I use ints for simplicity]
	duration.Left -= 1
	move_module.velocity.y -= force #Subtract the jump force from the Y value of velocity to continue moving up and not staying at the launch Y value
	
	if duration.Left <= 0: #If the jump duration has run up; then the jump has ended.
		jump_started = false #Jump started is false
		jump_count_left -= 1 #And remove a jump count
		reset_duration()


#This handles landing from an arial state
func landed():
	emit_signal("Landed") #Emit the landed signal
	reset_jump() #Reset the jump info


#This checks to see if the character can jump
func can_jump():
	if jump_count_left > 0: #If the jump count is 0 then there's no need to go further; they can't jump.
		return true
	
	return false #If anything else unchecked happens and the character hasn't been cleared for a jump; they can't jump then.

func jump_released():
	jump_started = false #Set jump started to false
	reset_duration() #Reset the jump duration
	jump_count_left -= 1 #And take away a jump count since the jump has ended

#This handles resetting the jump information
func reset_jump():
	jump_started = false #The jump is no longer started
	jump_count_left = jump_count_default #Reset the jump count
	reset_duration()
	
#	if wall_slide_settings.Active: #If wall sliding is active
#		wall_slide_settings.SlideCount.Current = wall_slide_settings.SlideCount.Max #Reset Slide Count

func reset_duration():
	duration.Left = duration.Default #Reset the jump duration

