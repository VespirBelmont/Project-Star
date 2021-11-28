extends Control

signal Button_Pressed

export var enabled = true

export (String, "Option_1", "Option_2", "Option_3", "Option_4", "PauseGame", "StartGame", "UpgradeMenu", "Interact") var keyboard_input
export (String, "Option_1", "Option_2", "Option_3", "Option_4", "PauseGame", "StartGame", "UpgradeMenu", "Interact") var controller_input

func _ready():
	if enabled:
		enable()
	else:
		disable()

func _input(event):
	if not enabled: return
	
	if keyboard_input == "" or controller_input == "":
		return
	
	var button_pressed = Input.is_action_just_pressed(keyboard_input) and ControlSettings.current_device == "Keyboard" or \
		Input.is_action_just_pressed(controller_input) and ControlSettings.current_device == "Controller"
	
	if button_pressed:
		emit_signal("Button_Pressed")


func disable():
	enabled = false
	$Anim.play("Disable")

func enable():
	enabled = true
	$Anim.play_backwards("Disable")
