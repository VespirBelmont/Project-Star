extends "res://Scripts/ModuleSettings.gd"

var ability_active = false

func activate():
	if $CooldownTimer.time_left != 0: return
	
	start_ghost_visual()
	
	ability_active = true
	
	
	$GhostDuration.start()
	$ActivateButton.disable()
	
	AudioServer.set_bus_volume_db(2, GameProgress.sfx_volume - 10)


func cooldown_finished():
	$ActivateButton.enable()


func ghost_chance_activated():
	start_ghost_visual()
	yield(get_tree().create_timer(3), "timeout")
	end_ghost_visual()

func start_ghost_visual():
	var ship_root = get_parent().get_parent().get_parent().get_parent().get_parent()
	var tween = $GhostTween
	var original_modulate = ship_root.modulate
	var ghost_modulate = Color(original_modulate.r, original_modulate.g, original_modulate.b, 0.4)
	
	tween.interpolate_property(ship_root, "modulate", original_modulate, ghost_modulate, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func end_ghost_visual():
	var ship_root = get_parent().get_parent().get_parent().get_parent().get_parent()
	var tween = $GhostTween
	var original_modulate = Color(1, 1, 1, 1)
	var ghost_modulate = Color(original_modulate.r, original_modulate.g, original_modulate.b, 0.4)
	
	tween.interpolate_property(ship_root, "modulate", ghost_modulate, original_modulate, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween, "tween_completed")
	ghost_ends()


func ghost_ends():
	AudioServer.set_bus_volume_db(2, GameProgress.sfx_volume )
	ability_active = false
	$CooldownTimer.start()


