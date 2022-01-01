extends Node2D

export var rate = {
						"Weak": 0.0,
						"Mild": 0.0,
						"Strong": 0.0,
						"Extreme": 0.0
					}

export var hit_amount = {
							"Weak": 1,
							"Mild": 2,
							"Strong": 3,
							"Extreme": 4
						}

var damage_amount = 1
var hits_left = 0



func setup(_severity):
	var new_rate = rate[_severity]
	
	hits_left = hit_amount[_severity]
	
	$EffectTimer.wait_time = new_rate
	$EffectTimer.start()
	
	print("setup se")

func inflict_damage():
	get_parent().get_parent().get_node("Modules/HealthSystem").take_damage(damage_amount, 0, self.global_position)
	$StatusAnim.play()
	$StatusSound.play()
	
	hits_left -= 1
	if hits_left > 0:
		$EffectTimer.start()
	else:
		queue_free()


