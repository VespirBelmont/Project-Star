extends Node2D

export (bool) var has_particles = false

export (int) var health_modifier = 0
export (int) var speed_modifier = 0
export (int) var damage_modifier = 0

func get_detail_count():
	var count = 0
	for detail in $SpriteList.get_children():
		count += 1
	
	return count

