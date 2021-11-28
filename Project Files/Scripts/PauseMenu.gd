extends Control

export (NodePath) var game_manager_path
onready var game_manager_node = get_node(game_manager_path)

var paused = false
var active = false
var can_input = true


func toggle_pause():
	if not can_input: return
	can_input = false
	
	match paused:
		true:
			paused = false
			$PauseAnim.play_backwards("Toggle")
			yield($PauseAnim, "animation_finished")
			active = false
		false:
			paused = true
			$PauseAnim.play("Toggle")
			yield($PauseAnim, "animation_finished")
			active = true
	get_tree().paused = paused
	
	cooldown_input()

func toggle_settings():
	if not can_input or not active: return
	can_input = false
	
	print("Settings")
	cooldown_input()

func quit_game():
	if not can_input or not active: return
	can_input = false
	
	game_manager_node.quit_game()
	cooldown_input()

func cooldown_input():
	yield(get_tree().create_timer(0.01), "timeout")
	can_input = true
