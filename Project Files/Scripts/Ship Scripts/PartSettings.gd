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
