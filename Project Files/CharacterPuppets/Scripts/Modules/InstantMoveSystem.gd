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

var move_speed_mod_store = 1

export (float, 0, 1) var air_control = 1 #How much control the character has in the air [0 = No control | 1 = Full Control] 
var velocity = Vector2() #This is the overall speed the character is moving at
var direction = Vector2() #This is the direction the character is moving

export (float) var gravity #The gravity amount that'll pull the character down
export (float) var gravity_fall_mod #The amount gravity is modified when falling [More in the Documentation Document]

var boost = Vector2(0, 0)
var knockback_mod = Vector2(0, 0)

func _ready():
	move_speed = move_speeds[default_move_state_mod]

func move():
	var final_velocity = Vector2()
	
	#If the ship is being knocked back it shouldn't move
	if knockback_mod == Vector2():
		final_velocity +=  velocity
		final_velocity += boost
	final_velocity -= knockback_mod
	
	velocity = controller.move_and_slide(final_velocity, Vector2.UP) #The character is moved by their velocity

func move_to(_target = get_parent(), forced_position = null, delta = 1):
	var move_dir
	
	if forced_position == null:
		move_dir = (_target.global_position - controller.global_position).normalized()
	else:
		move_dir = (forced_position - controller.global_position).normalized()
	var vel = (move_dir * move_speed) * delta
	
	velocity = vel
	move()


func boost(_boost_power, _boost_duration):
	boost.x = _boost_power
	
	$BoostDuration.wait_time = _boost_duration
	$BoostDuration.start()

func end_boost():
	boost.x = 0
	boost.y = 0

func ram(_ram_power, _ram_duration):
	boost.y = _ram_power
	
	$BoostDuration.wait_time = _ram_duration
	$BoostDuration.start()

func knockback(power, duration):
	knockback_mod = power
	
	if duration is Vector2: return
	
	$KnockbackDuration.wait_time = duration
	$KnockbackDuration.start()

func end_knockback():
	knockback_mod = Vector2()

func slow(_duration):
	print("InstantMoveSystem.gd / Slow")
	move_speed_mod_store = move_speed_mod
	
	move_speed_mod *= 0.3
	$SlowDuration.wait_time = _duration
	$SlowDuration.start()

func end_slow():
	if move_speed_mod < move_speed_mod_store:
		move_speed_mod = move_speed_mod_store
		print("InstantMoveSystem.gd / End Slow")


