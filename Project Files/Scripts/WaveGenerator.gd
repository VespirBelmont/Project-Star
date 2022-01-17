extends Node

var spawn_pos = Vector2()
export (float) var spawn_move_speed = 20

export (int) var waves_between_bosses = 500
onready var waves_until_boss = waves_between_bosses

var generate_timer
export (float) var time_between_waves = 15
export (float) var distance_limit = 400

export (float) var chance_for_hazard = 3

#This handles the node initialization
func _ready():
	
	#TIMER SETUP#
	generate_timer = Timer.new() #Creates a timer node
	add_child(generate_timer) #Adds the timer node to the game
	generate_timer.connect("timeout", self, "generate_wave") #Connects the timeout signal to the generate wave function
	generate_timer.wait_time = time_between_waves #Sets the timer wait time
	generate_timer.start() #Starts the timer

#This runs every tick
func _process(delta):
	var player_position = abs(get_parent().get_node("Players/P1").global_position.y)
	
	#If the position difference is within the distance zone
	if  player_position - abs(spawn_pos.y) <= distance_limit:
		if generate_timer.time_left == 0: #If the time left is at 0 then start the timer again
			generate_timer.start()
		
		spawn_pos.y -= (spawn_move_speed * delta) #This moves the spawner Y Position
	else: #If the spawner isn't within the distance zone
		generate_timer.stop() #The generation timer stops


#This handles wave generation
func generate_wave():
	var wave_template = $WaveTemplates.get_child(randi()%($WaveTemplates.get_child_count()-1))
	wave_template.global_position.y = spawn_pos.y
	
	for enemy in wave_template.get_children():
		
		var rand_num = randi()%10
		if rand_num <= chance_for_hazard:
			generate_hazard(enemy.global_position)
		else:
			generate_enemy(enemy.global_position)
		
		if waves_until_boss <= 0:
			reset_wave_count()
	
	waves_until_boss -= 1


func generate_enemy(_position):
	var elevation_level = get_parent().get_node("World").elevation_level
	var enemy_list = $EnemyList.get_node("Elevation_%s" % elevation_level)
	var _new_enemy
	var parent = get_parent().get_node("Enemies")
	
	if waves_until_boss <= 0:
		_new_enemy = enemy_list.get_node("Bosses").get_child(randi()%(enemy_list.get_node("Bosses").get_child_count()-1)).duplicate()
	else:
		_new_enemy = $EnemyList.create_enemy(elevation_level, parent, _position)

func generate_hazard(_position):
	var elevation_level = get_parent().get_node("World").elevation_level
	var hazard_list = $HazardList.get_node("Elevation_%s" % elevation_level)
	var _new_hazard
	var parent = get_parent().get_node("Hazards")
	
	_new_hazard = $HazardList.create_hazard(elevation_level, parent, _position)

func reset_wave_count():
	waves_until_boss = waves_between_bosses

