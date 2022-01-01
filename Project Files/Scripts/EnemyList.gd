extends Node

var category = "Grunt"

var category_rates = {
						"Grunt": 70,
						"Adept": 50,
						"Elite": 30,
					}


func get_category():
	randomize()
	
	var rand_num = randi()%100
	
	if rand_num <= category_rates.Elite:
		category = "Elite"
		return
	
	elif rand_num <= category_rates.Adept:
		category = "Adept"
		return
	
	category = "Grunt"


func create_enemy(elevation, parent, _position):
	randomize()
	
	get_category()
	yield(get_tree().create_timer(0.2), "timeout")
	
	var rand_num = randi()%(get_node("Elevation_%s" % elevation).get_node(category).get_child_count())
	var enemy_node = get_node("Elevation_%s" % elevation).get_node(category).get_child(rand_num)
	var new_enemy = enemy_node.enemy_tscn.instance()
	
	
	parent.call_deferred("add_child", new_enemy)
	
	if enemy_node.is_in_group("Unit"):
		new_enemy.call_deferred("start_up")
	
	new_enemy.set_deferred('global_position', _position)


