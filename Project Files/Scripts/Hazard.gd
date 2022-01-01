extends Area2D

signal HitObject

export (String, "Standard", "Corrosive", "Ice", "Shock") var damage_type = "Standard"
export (String, "Weak", "Mild", "Strong", "Extreme") var damage_severity = "Weak"
export (int) var damage = 1
export (int) var knockback = 5
export (Array, String, "Enemy", "Player", "Hazardprint") var targets = ["Player"]


export (PackedScene) var corrosion_status_effect
export (PackedScene) var ice_status_effect
export (PackedScene) var shock_status_effect

export (String) var cam_effect = ""

func body_hit(body):
	for tag in targets:
		if body.is_in_group(tag):
			body.get_node("Modules/HealthSystem").take_damage(damage, knockback, self.global_position)
			
			if body.is_in_group("Player"):
				body.get_node("Modules/CamFX").play_effect(cam_effect)
			emit_signal("HitObject")


func destroy():
	self.call_deferred("free")


