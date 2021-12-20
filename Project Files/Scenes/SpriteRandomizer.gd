extends Sprite

export (Array, Texture) var sprite_list

export (bool) var flip_sprite = true

func _ready():
	randomize_sprite()

func randomize_sprite():
	randomize()
	
	var rand_num = randi()%(sprite_list.size()-1)
	var new_sprite = sprite_list[rand_num]
	
	self.texture = new_sprite
	
	if flip_sprite:
		if randi()%10 <= 5:
			self.flip_h = true


