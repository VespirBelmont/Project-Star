extends "res://Scripts/ModuleSettings.gd"

signal Ram

export (float) var boost_power = 1
export (float) var boost_duration = 1

var ram_pressed = 0
var ability_active = false

func _ready():
	var module_root = get_parent().get_parent()
	var ship_root = module_root.get_parent().get_parent().get_parent()
	
	if ship_root.name == "UpgradeSystem":
		return
	
	self.connect("Ram", ship_root.get_node("Modules/InstantMoveSystem"), "ram")


func use_ram():
	if $UseCooldown.time_left != 0:
		return
	
	if not equipped:
		return
	
	
	$ButtonTapReset.start()
	
	ram_pressed += 1
	
	if ram_pressed < 2:
		return
	else:
		$Sounds/ActiveSound.play()
		emit_signal("Ram" ,boost_power ,boost_duration)
		ability_active = true
		
		reset_taps()
		$UseCooldown.start()
	
	yield(get_tree().create_timer(boost_duration), "timeout")
	ability_active = false
	$Sounds/ActiveSound.stop()


func reset_taps():
	ram_pressed = 0
	$ButtonTapReset.stop()

func cooled_down():
	$Sounds/ReadySound.play()


