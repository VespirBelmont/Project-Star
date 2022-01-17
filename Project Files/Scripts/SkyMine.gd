extends "res://Scripts/Hazard.gd"

signal Exploded

var triggered = false

var hit_body

export (String, "StandardExplode", "CorrosiveExplode", "FrostExplode", "ShockExplode") var explosion_anim = "StandardExplode"

func check_body(area):
	for tag in targets:
		if area.is_in_group(tag):
			hit_body = area
			trigger_mine()
			break

func trigger_mine():
	if triggered: return
	
	triggered = true
	$Hitbox/AreaCollider.set_deferred("disabled", true)
	
	$Visual/Anim.play("Triggered")
	yield($Visual/Anim, "animation_finished")
	
	$Visual/Anim.play(explosion_anim)
	$AreaCollider.set_deferred("disabled", false)
	emit_signal("Exploded", damage)
	
	#yield($Visual/Anim, "animation_finished")
	if hit_body == null: return
	
	var status_container = hit_body.get_parent().get_parent().get_parent().get_node("StatusEffects")
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
	
	yield(get_tree().create_timer(1), "timeout")
	destroy()

func area_exited(area):
	if area == hit_body:
		hit_body = null


