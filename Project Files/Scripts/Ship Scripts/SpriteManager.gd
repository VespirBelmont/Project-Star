extends Node2D

export var sprite_library = {
						}


func update_visual(_sprite_name):
	for part in self.get_children():
		if part.name != _sprite_name:
			part.hide()
		else:
			part.show()

