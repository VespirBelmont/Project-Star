extends Node2D

export (float) var rotate_speed = 1


func _process(delta):
	rotation_degrees += rotate_speed
