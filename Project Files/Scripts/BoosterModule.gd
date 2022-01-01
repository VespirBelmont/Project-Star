extends "res://Scripts/ModuleSettings.gd"

signal Boost

export (float) var boost_power = 1
export (float) var boost_duration = 1

var right_button_taps = 0
var left_button_taps = 0

func _ready():
	var module_root = get_parent().get_parent()
	var ship_root = module_root.get_parent().get_parent().get_parent()
	
	if ship_root.name == "UpgradeSystem":
		return
	
	self.connect("Boost", ship_root.get_node("Modules/InstantMoveSystem"), "boost")

func use_booster(_side):
	if $UseCooldown.time_left != 0:
		return
	
	if not equipped:
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
		$Sounds/ActivateSound.play()
		if right_button_taps > left_button_taps:
			emit_signal("Boost", 1 * boost_power, boost_duration)
		else:
			emit_signal("Boost", -1 * boost_power, boost_duration)
		
		reset_taps()
		$UseCooldown.start()


func reset_taps():
	right_button_taps = 0
	left_button_taps = 0
	$ButtonTapReset.stop()

func cooled_down():
	$Sounds/ReadySound.play()
