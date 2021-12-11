extends "res://Scenes/Characters/Ship Parts/Wings/ModuleSettings.gd"

signal Boost

var right_button_taps = 0
var left_button_taps = 0

func use_booster(_side):
	if $UseCooldown.time_left != 0 or not equipped:
		return
	
	
	$ButtonTapReset.start()
	
	match _side:
		"Right":
			right_button_taps += 1
		
		"Left":
			left_button_taps += 1
	
	if right_button_taps < 2 and left_button_taps < 2:
		return
	else:
		if right_button_taps > left_button_taps:
			emit_signal("Boost", "Right")
			print("BOOST: Right")
		else:
			emit_signal("Boost", "Left")
			print("BOOST: Left")
		reset_taps()
		$UseCooldown.start()


func reset_taps():
	right_button_taps = 0
	left_button_taps = 0
	$ButtonTapReset.stop()


