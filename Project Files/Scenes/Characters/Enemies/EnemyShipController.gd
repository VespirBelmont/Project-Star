extends "res://Scripts/Ship Scripts/ShipController.gd"

func set_state(_state):
	match _state:
		"Dead":
			$Modules/HealthSystem/Hitbox/AreaCollider.set_deferred("disabled", true)
