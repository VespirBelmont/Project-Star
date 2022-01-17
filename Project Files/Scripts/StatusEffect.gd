extends Node2D

signal AllSet
signal HitsLeftDone

onready var root = get_parent().get_parent()

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

var severity

export (Color) var normal_color
export (Color) var effect_color

func setup(_severity):
	var new_rate = rate[_severity]
	
	severity = _severity
	
	hits_left = hit_amount[_severity]
	
	if $EffectTimer.wait_time != 0:
		$EffectTimer.wait_time = new_rate
		$EffectTimer.start()
	
	emit_signal("AllSet")

func inflict_damage():
	root.get_node("Modules").get_node("HealthSystem").take_damage(damage_amount, 0, self.global_position)
	$StatusAnim.play()
	$StatusSound.play()
	
	hits_left -= 1
	if hits_left > 0:
		$EffectTimer.start()
	else:
		emit_signal("HitsLeftDone")
		$EffectTimer.stop()
		yield(get_tree().create_timer(0.5), "timeout")
		queue_free()

func change_color(_type):
	var tw = $Tween
	
	match _type:
		"ToEffect":
			tw.interpolate_property(root, "modulate", root.modulate, effect_color, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		"ToNormal":
			tw.interpolate_property(root, "modulate", root.modulate, normal_color, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tw.start()
