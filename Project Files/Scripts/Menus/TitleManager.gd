extends Node

var can_input = true

export (PackedScene) var gameplay_tscn


func play_game():
	if not can_input: return
	can_input = false
	
	$ShipSprite/ShipAnim.play("StartGame")
	yield($ShipSprite/ShipAnim, "animation_finished")
	$TitleAnim.play_backwards("Fade")
	yield(get_tree().create_timer(1.2), "timeout")
	
	get_tree().change_scene_to(gameplay_tscn)

func quit_game():
	get_tree().quit()

