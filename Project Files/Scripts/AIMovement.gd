extends Node

export (Vector2) var movement_direction
export (float) var move_speed

export (float) var switch_dir_time_min
export (float) var switch_dir_time_max

func _ready():
	set_physics_process(false)
	
	$SwitchDirectionTimer.connect("timeout", self, "switch_direction")

func start_up():
	var switch_time = rand_range(switch_dir_time_min, switch_dir_time_max)
	$SwitchDirectionTimer.wait_time = switch_time
	$SwitchDirectionTimer.start()
	
	set_physics_process(true)


func _physics_process(_delta):
	var move_module = get_parent().get_node("Modules/InstantMoveSystem")
	var vel = movement_direction * move_speed
	
	move_module.velocity = vel
	move_module.move()

func switch_direction():
	movement_direction *= -1
