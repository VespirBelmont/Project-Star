extends Node

onready var controller = get_parent().get_parent()

export (String, "Walk", "Run", "Sprint") var default_move_state_mod = "Walk" #This is what state mod will be used by default for the Move State

export var accelerations = {"Walk": 0.0, "Run": 0.0, "Sprint": 0.0} #Acceleration Presets 
export var decelerations = {"Walk": 0.0, "Run": 0.0, "Sprint": 0.0} #Decelerate Presets
var acceleration = 0.0 #How fast the character accelerates to the top speed
var deceleration = 0.0 #How fast the character slows down

export var speed_max = 0.0 #The top speed the character can move
export var decelerate_in_air = true #Determines if you can slow down/stop in the air

export (float, 0, 1) var air_control = 1 #How much control the character has in the air [0 = No control | 1 = Full Control] 
var velocity = Vector2() #This is the overall speed the character is moving at
var direction = Vector2() #This is the direction the character is moving

export (float) var gravity #The gravity amount that'll pull the character down
export (float) var gravity_fall_mod #The amount gravity is modified when falling [More in the Documentation Document]



func _ready():
	acceleration = accelerations[default_move_state_mod]
	deceleration = decelerations[default_move_state_mod]


#This handles applying gravity to the character
func apply_gravity(delta):
	var final_gravity = gravity #This will allow us to modify the value of gravity without changing it
	
	if (velocity.y > 0): #If the character is falling
		final_gravity += gravity_fall_mod #Gravity Fall modifier is added to the final gravity
	
	if controller.state == "WallSlide": #If the character is wall sliding
		velocity.y = 0 #Velocity's Y value is set to 0 so only the slide gravity is moving the character
		final_gravity = controller.wall_slide_settings.SlideGravity #Then we set final gravity to the Slide gravity
	
	velocity.y += final_gravity * delta #Then we add the final gravity smoothed out with delta which will move the character down nicely


#This handles increasing the character's velocity
func accelerate():
	if controller.is_on_floor(): #If they're on the floor we can just accelerate by accelerate times the direction the character is moving in
		velocity.x += acceleration * direction.x
	else: #If they're not on the floor we need to factor in air control
		velocity.x += (acceleration * direction.x) * air_control
	
	#Then clamp the velocity to make sure the character isn't going slower or faster than allowed
	velocity.x = clamp(velocity.x, -speed_max, speed_max)


#This handles the decreasing of the character's velocity
func decelerate():
	velocity.x -= deceleration * direction.x #Decrease velocity by the deceleration speed in the direction they're moving
	velocity.x = clamp(velocity.x, -speed_max, speed_max) #Clamp to avoid unwanted speeds
	
	#If the velocity is under a threshold then set it to 0; this makes movement feel better.
	if abs(velocity.x) <= 5: velocity.x = 0




