extends Node2D

export (bool) var has_particles = false

export (int) var health_modifier = 0
export (int) var speed_modifier = 0
export (int) var damage_modifier = 0

export (String, "Player", "Enemy") var party = "Player"

func _ready():
	var ship_root = get_parent().get_parent()
	
	if "Preview" in ship_root.name:
		$Modules.hide()

func get_detail_count():
	var count = 0
	for detail in $SpriteList.get_children():
		count += 1
	
	return count

