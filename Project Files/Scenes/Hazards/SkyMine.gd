extends "res://Scripts/Hazard.gd"


export (String, "Standard", "Corrosive", "Ice", "Shock") var damage_type = "Standard"
var triggered = false

func check_body(body):
	for tag in targets:
		if body.is_in_group(tag):
			trigger_mine()
			break

func trigger_mine():
	if triggered: return
	
	triggered = true
	$Hitbox/AreaCollider.set_deferred("disabled", true)
	
	$Visual/Anim.play("Triggered")
	yield($Visual/Anim, "animation_finished")
	
	$Visual/Anim.play("Explode")
	$AreaCollider.set_deferred("disabled", false)
	yield($Visual/Anim, "animation_finished")
	
	destroy()

