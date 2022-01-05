extends Control

signal Button_Pressed

signal Activate
signal Deactivate

export var enabled = true

export (String, "Option_1", "Option_2", "Option_3", "Option_4", "PauseGame", "StartGame", "UpgradeMenu", "ColorMenu", "ModMenu", "Interact", "ShipRandomizer", "Back", "Ability_1", "Discord") var keyboard_input
export (String, "Option_1", "Option_2", "Option_3", "Option_4", "PauseGame", "StartGame", "UpgradeMenu", "ColorMenu", "ModMenu", "Interact", "ShipRandomizer", "Back", "Ability_1", "Discord") var controller_input

export (AudioStream) var pressed_sound
export (float) var pressed_volume

export (float) var input_cooldown = 0.2

var can_input = true

var activated = false

func _ready():
	if enabled:
		enable()
	else:
		disable()
	
	if pressed_sound == null: return
	
	$PressedAudio.stream = pressed_sound
	$PressedAudio.volume_db = pressed_volume

func _input(event):
	if not enabled or not can_input: return
	
	can_input = false
	
	if keyboard_input == "" or controller_input == "":
		return
	
	var button_pressed = Input.is_action_just_pressed(keyboard_input) and ControlSettings.current_device == "Keyboard" or \
		Input.is_action_just_pressed(controller_input) and ControlSettings.current_device == "Controller"
	
	if button_pressed:
		if activated:
			activated = false
			emit_signal("Deactivate")
		else:
			activated = true
			emit_signal("Activate")
		emit_signal("Button_Pressed")
	
	if input_cooldown > 0:
		yield(get_tree().create_timer(input_cooldown), "timeout")
	can_input = true

func toggle_label(label_1, label_2):
	var label = $OptionLabel.text
	
	if label == label_1:
		$OptionLabel.text = label_2
		return
	else:
		$OptionLabel.text = label_1

func disable():
	enabled = false
	$Anim.play("Disable")

func enable():
	enabled = true
	$Anim.play("Enable")

