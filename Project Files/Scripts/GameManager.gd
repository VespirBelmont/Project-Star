extends Node

var player_1
var player_2
var game_over = false

func _ready():
	setup_game()

func setup_game():
	#This collects the player information
	for player in $Players.get_children():
		match player.player_id:
			1:
				player_1 = player
				$Interface/Interface/Player_1.setup(player_1)
			2:
				player_2 = player
				#$CanvasLayer/Interface/Player_2.setup(player_2)
	
	#This sets up the player health systems
	if player_1 != null:
		$Players/P1/Modules/HealthSystem.connect("Hurt", $Interface/Interface/Player_1, "update_health")
		$Players/P1/Modules/HealthSystem.connect("Hurt", $Interface/Interface/Player_1, "player_hurt")
		$Players/P1/Modules/HealthSystem.connect("Dead", self, "players_dead")
		$Players/P1/Modules/HealthSystem.connect("Healed", $Interface/Interface/Player_1, "update_health")
		$Players/P1/Modules/HealthSystem.heal(999)


func quit_game():
	get_tree().paused = false
	get_tree().change_scene("res://Scenes/Title.tscn")

func players_dead():
	game_over = true
	$Interface/Interface/DeathScreen.death_intiate()

func _process(delta):
	if $Players/P1.move_module.velocity != Vector2():
		if not $CamRig.is_processing():
			$CamRig.run_cam()
			set_process(false)


func restart_game():
	get_tree().reload_current_scene()
