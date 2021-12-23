extends Node

var spawn_pos = Vector2()
export (float) var spawn_move_speed = 20

export (int) var waves_between_bosses = 500
onready var waves_until_boss = waves_between_bosses

var generate_timer
export (float) var time_between_waves = 15
export (float) var distance_limit = 400

func _ready():
	generate_timer = Timer.new()
	add_child(generate_timer)
	generate_timer.connect("timeout", self, "generate_wave")
	generate_timer.one_shot = false
	generate_timer.wait_time = time_between_waves
	generate_timer.start()


func _process(delta):
	
	if abs(get_parent().get_node("Players/P1").global_position.y) - abs(spawn_pos.y) <= distance_limit:
		if generate_timer.time_left == 0:
			generate_timer.start()
		spawn_pos.y -= spawn_move_speed * delta
	else:
		generate_timer.stop()

func generate_wave():
	var wave_template = $WaveTemplates.get_child(randi()%($WaveTemplates.get_child_count()-1))
	wave_template.global_position.y = spawn_pos.y
	
	for enemy in wave_template.get_children():
		generate_enemy(enemy.global_position)
		
		if waves_until_boss <= 0:
			reset_wave_count()
	
	waves_until_boss -= 1


func generate_enemy(_position):
	var elevation_level = get_parent().get_node("World").elevation_level
	var enemy_list = $EnemyList.get_node("Elevation_%s" % elevation_level)
	var new_enemy
	var parent = get_parent().get_node("Enemies")
	
	if waves_until_boss <= 0:
		new_enemy = enemy_list.get_node("Bosses").get_child(randi()%(enemy_list.get_node("Bosses").get_child_count()-1)).duplicate()
	else:
		new_enemy = $EnemyList.create_enemy(elevation_level, parent, _position)

func reset_wave_count():
	waves_until_boss = waves_between_bosses

