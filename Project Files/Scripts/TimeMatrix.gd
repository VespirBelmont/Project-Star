extends "res://Scripts/ModuleSettings.gd"

export (Color) var passive_color
export (Color) var active_color
onready var color_used = passive_color

export (float) var slow_modifier = 0.5

var ability_active = false

func activate():
	$ActivateButton.disable()
	$AreaInfluencePassive/Anim.play_backwards("Toggle")
	$AreaInfluencePassive.set_process(false)
	$AreaInfluenceActive/InfluenceArea.set_deferred("disabled", false)
	$AreaInfluenceActive/Anim.play("Toggle")
	ability_active = true
	
	$DurationTimer.start()

func deactivate():
	$AreaInfluenceActive/InfluenceArea.set_deferred("disabled", true)
	$AreaInfluenceActive/Anim.play_backwards("Toggle")
	ability_active = false
	$AreaInfluencePassive.set_process(true)
	$AreaInfluencePassive/Anim.play("Toggle")
	$CooldownTimer.start()

func change_color(_type):
	match _type:
		"Active":
			color_used = active_color
		"Passive":
			color_used = passive_color

func projectile_hit(area):
	var ship_root = get_parent().get_parent().get_parent().get_parent().get_parent()
	var _owner = get_parent().get_parent().party
	
	if area.is_in_group("CanSlow"):
		if area.is_in_group(_owner):
			return 
		
		if $DurationTimer.time_left != 0:
			$AreaInfluenceActive/Anim.play("ProjectileHit")
		$AreaInfluencePassive/Anim.play("ProjectileHit")
		
		area.move_speed = area.move_speed * slow_modifier

func projectile_left_influence(area):
	var ship_root = get_parent().get_parent().get_parent().get_parent().get_parent()
	var _owner = get_parent().get_parent().party
	
	if area.is_in_group("CanSlow"):
		if area.is_in_group(_owner):
			return 
		
		area.move_speed = area.move_speed * (1 + slow_modifier)
