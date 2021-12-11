extends Node

export (Color) var color

export (bool) var unlocked = false
export (bool) var equipped = false

func randomize_color():
	randomize()
	
	var red = rand_range(0, 1)
	var green = rand_range(0, 1)
	var blue = rand_range(0, 1)
	
	var new_color = Color(red, green, blue)
	color = new_color
