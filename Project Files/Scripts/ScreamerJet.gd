extends "res://Scripts/EnemyShipController.gd"

var player 
var move_target

export (int) var fly_by_attempts = 3
onready var fly_by_attempts_left = fly_by_attempts

func _ready():
	set_physics_process(false)
	player = get_parent().get_parent().get_node("Players/P1")
	
	$Modules/LookAt.set_target(player)
	start_movement()

func start_movement():
	$Modules/LookAt.set_target(player)
	look_at(player.global_position)
	#$Modules/LookAt.look()
	self.rotation_degrees += 85
	move_target = player.global_position
	yield(get_tree().create_timer(1), "timeout")
	set_physics_process(true)


func end_movement():
	set_physics_process(false)
	
	fly_by_attempts_left -= 1
	
	if fly_by_attempts_left <= 0:
		destroy()
	else:
		$MovementCooldownTimer.start()

func _physics_process(delta):
	var move_speed = $Modules/InstantMoveSystem.move_speed
	var dir
	var vel = Vector2(0, -move_speed).rotated(rotation) * delta
	
	$Modules/InstantMoveSystem.velocity = vel
	$Modules/InstantMoveSystem.move()
	
	return
	
	#Move to target location method
	dir = (move_target - self.global_position)
	
	if dir.x > 0: dir.x = 1
	else: dir.x = -1
	
	if dir.y > 0: dir.y = 1
	else: dir.y = -1
	
	vel = (move_speed * dir) * delta
	
	$Modules/InstantMoveSystem.velocity = vel
	$Modules/InstantMoveSystem.move()
	
	var distance_from_target = move_target - self.global_position
	#print(distance_from_target)
	if abs(distance_from_target.x) < 20 and abs(distance_from_target.y) < 20:
		end_movement()





