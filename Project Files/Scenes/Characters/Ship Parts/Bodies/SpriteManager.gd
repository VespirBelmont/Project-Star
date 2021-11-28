extends Node2D

func update_colors(_detail, _color):
	for sprite in get_node(_detail).get_children():
		sprite.module = _color
