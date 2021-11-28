extends Node

signal Update_Prompts

var current_device = "Keyboard"
var controller_preference = "Xbox"

func check_for_device(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		current_device = "Controller"
	
	if event is InputEventKey or event is InputEventMouseMotion or event is InputEventMouseButton:
		current_device = "Keyboard"
	
	emit_signal("Update_Prompts")

func update_controller_preference(_new_preference):
	controller_preference = _new_preference
	emit_signal("Update_Prompts")

