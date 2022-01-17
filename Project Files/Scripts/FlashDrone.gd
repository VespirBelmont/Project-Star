extends "res://Scripts/EnemyShipController.gd"

func _physics_process(delta):
	follow_target(delta)

func follow_target(delta):
	
	var player = get_parent().get_parent().get_node("Players/P1")
	move_module.move_to(player, null, delta)
	
	look_at(player.global_position)
	rotation_degrees += 85

func release_bombs():
	var hazard_container = get_parent().get_parent().get_node("Hazards")
	
	for bomb in $Bombs.get_children():
		var current_pos = bomb.global_position
		bomb.get_parent().remove_child(bomb)
		hazard_container.add_child(bomb)
		bomb.trigger_mine()
		bomb.global_position = current_pos
