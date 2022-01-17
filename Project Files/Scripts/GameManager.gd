extends Node

var player_1 #This is the player 1 node
var player_2 #This is the player 2 node


#This handles the initialization process
func _ready():
	setup_game() #Sets up the game


#This handles setting up the game for play
func setup_game():
	#This collects the player information
	for player in $Players.get_children():
		match player.player_id:
			1:
				player_1 = player
				$Interface/Interface/Player_1.setup(player_1)
			2:
				player_2 = player
				#$CanvasLayer/Interface/Pl7ayer_2.setup(player_2)
	
	#This sets up the player health systems
	if player_1 != null:
		$Players/P1/Modules/HealthSystem.connect("Hurt", $Interface/Interface/Player_1, "update_health")
		$Players/P1/Modules/HealthSystem.connect("Hurt", $Interface/Interface/Player_1, "player_hurt")
		$Players/P1/Modules/HealthSystem.connect("Dead", self, "game_over")
		$Players/P1/Modules/HealthSystem.connect("Healed", $Interface/Interface/Player_1, "update_health")
		$Players/P1/Modules/HealthSystem.heal(999)


func _process(_delta):
	if $Players/P1.move_module.velocity != Vector2():
		if not $CamRig.is_processing():
			$CamRig.run_cam()
			set_process(false)


#This handles what happens during a game over
func game_over():
	get_tree().change_scene("res://Scenes/Menus/Title.tscn")
	#$Interface/Interface/DeathScreen.death_intiate() #This starts up the death screen


#This handles quitting the game
func quit_game():
	get_tree().paused = false #The game is unpaused to create less isuees
	get_tree().change_scene("res://Scenes/Title.tscn") #And the scene is changed back to the title screen

