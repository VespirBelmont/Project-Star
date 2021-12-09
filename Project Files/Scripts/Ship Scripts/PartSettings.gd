extends Node2D

export (bool) var preview_mode = false
export (bool) var has_particles = false

export (int) var health_modifier = 0
export (int) var speed_modifier = 0
export (int) var damage_modifier = 0


func _ready():
	if preview_mode:
		$GameplaySprite.hide()
		$PreviewSprite.show()
	else:
		$GameplaySprite.show()
		$PreviewSprite.hide()

func get_detail_count():
	var count = 0
	for detail in $GameplaySprite.get_children():
		if "Detail" in detail.name:
			count += 1
	
	return count

