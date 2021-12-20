extends Node

var can_input = true

export (PackedScene) var gameplay_tscn

#func _ready():
	#$ShipManager.ship_randomizer()

func play_game():
	if not can_input: return
	can_input = false
	
	$CanvasLayer/TitleInfo/Anim.stop()
	
	$TitleSubAnim.play("StartGame")
	yield($TitleSubAnim, "animation_finished")
	yield(get_tree().create_timer(0.2), "timeout")
	
	get_tree().change_scene_to(gameplay_tscn)

func quit_game():
	get_tree().quit()

