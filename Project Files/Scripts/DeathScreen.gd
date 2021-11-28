extends Control

signal Play_Again
signal Quit

var can_input = false

func toggle_input(value):
	can_input = value

func death_intiate():
	get_tree().paused = true
	$Anim.play("Death")
	toggle_input(true)

func play_again():
	if not can_input: return
	
	toggle_input(false)
	emit_signal("Play_Again")

func quit():
	if not can_input: return
	
	toggle_input(false)
	emit_signal("Quit")

