extends Node

onready var controller = get_parent().get_parent()
var wall_slide_module

export (String, "Walk", "Run", "Sprint") var default_move_state_mod = "Walk" #This is what state mod will be used by default for the Move State

export var move_speeds = { #Move speeds if the character is using instant movement
							  "Walk": 0.0,
							  "Run": 0.0,
							  "Sprint": 0.0,
								}

var move_speed = 0.0
export var accelerate_speed = 30
export var brake_speed = 30
export var auto_move_speed = 10
var move_speed_mod = 1

export (float, 0, 1) var air_control = 1 #How much control the character has in the air [0 = No control | 1 = Full Control] 
var velocity = Vector2() #This is the overall speed the character is moving at
var direction = Vector2() #This is the direction the character is moving

export (float) var gravity #The gravity amount that'll pull the character down
export (float) var gravity_fall_mod #The amount gravity is modified when falling [More in the Documentation Document]



func _ready():
	move_speed = move_speeds[default_move_state_mod]


#This handles applying gravity to the character
func apply_gravity(delta):
	var final_gravity = gravity #This will allow us to modify the value of gravity without changing it
	
	velocity.y += final_gravity * delta #Then we add the final gravity smoothed out with delta which will move the character down nicely

func move():
	velocity = controller.move_and_slide(velocity, Vector2.UP) #The character is moved by their velocity

#This handles changing the direction of the character
func update_direction():
	if direction.y == 1: #If the character is moving right
		controller.get_node("DirectionAnim").play("Up") #Play the right animation
	elif direction.y == -1: #If the character is moving left
		controller.get_node("DirectionAnim").play("Down") #Play the left animation

