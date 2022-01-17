extends Control

func _ready():
	ControlSettings.connect("Update_Prompts", self, "update_prompts")

func setup(_key, _button):
	if _key == null: return
	$Keyboard/Anim.play(_key)

func _input(event):
	ControlSettings.check_for_device(event)

func update_prompts():
	var prompt = ControlSettings.current_device
	var preference = ControlSettings.controller_preference
	
	for main_prompt in get_children():
		if not "Anim" in main_prompt.name:
			if main_prompt.name != prompt:
				main_prompt.hide()
			else:
				main_prompt.show()
				
				if main_prompt.name == "Controller":
					for sub_prompt in main_prompt.get_children():
						if sub_prompt.name != preference:
							sub_prompt.hide()
						else:
							sub_prompt.show()

func button_pressed():
	$Anim.play("Pressed")

