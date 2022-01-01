extends "res://Scripts/Hazard.gd"


var triggered = false

var hit_body

func check_body(body):
	for tag in targets:
		if body.is_in_group(tag):
			hit_body = body
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
	
	if hit_body == null: return
	
	var status_container = hit_body.get_node("StatusEffects")
	
	match damage_type:
		"Corrosive":
			var instance = corrosion_status_effect.instance()
			status_container.add_child(instance)
			instance.setup(damage_severity)
		
		"Ice":
			var instance = ice_status_effect.instance()
			status_container.add_child(instance)
			instance.setup(damage_severity)
		
		"Shock":
			var instance = shock_status_effect.instance()
			status_container.add_child(instance)
			instance.setup(damage_severity)
	
	destroy()

