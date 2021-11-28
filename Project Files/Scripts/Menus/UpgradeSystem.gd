extends Node2D

var active = false
var can_input = true

var current_section = "Selection"
var focused_part = ""


func toggle():
	if not can_input: return
	can_input = false
	
	if active:
		active = false
	else:
		active = true
	
	match active:
		true:
			get_tree().paused = true
			$Anim.play("ToggleSystem")
			change_section("Selection")
		
		false:
			if current_section == "Customization":
				$Anim.play_backwards("ToggleCustomization")
				yield($Anim, "animation_finished")
			
			$Anim.play_backwards("ToggleSystem")
			yield($Anim, "animation_finished")
			change_section("")
			get_tree().paused = false
	
	yield(get_tree().create_timer(0.1), "timeout")
	can_input = true


func change_section(_new_section):
	current_section = _new_section
	
	match current_section:
		"Selection":
			
			for wing in $Customization/PartList/Wings.get_children():
				if wing.equipped:
					$AreaSelection/WeaponLeft/ButtonPrompt.enable()
					$AreaSelection/WeaponRight/ButtonPrompt.enable()
					break
				
				$AreaSelection/WeaponLeft/ButtonPrompt.disable()
				$AreaSelection/WeaponRight/ButtonPrompt.disable()
			
			$Customization.revert_to_equipped()
			
			$Customization/PreviousItem.disable()
			$Customization/NextItem.disable()
			$Customization/Back.disable()
		
		"Customization":
			$Customization/PreviousItem.enable()
			$Customization/NextItem.enable()
			$Customization/Back.enable()

func customize_part(_selected_part):
	if not active or not can_input or focused_part != "": return
	can_input = false
	
	focused_part = _selected_part
	$Customization.update_area(focused_part)
	
	if current_section == "Selection":
		$Anim.play("ToggleCustomization")
		change_section("Customization")
	
	input_cooldown()



func go_back():
	if not active or not can_input or current_section == "Selection": return
	can_input = false
	
	match current_section:
		"Selection":
			toggle()
		
		"Customization":
			$Customization.current_area = ""
			focused_part = ""
			
			if not $VisualManager_Preview.wing_check():
				input_cooldown()
				$AreaSelection/WeaponLeft/ButtonPrompt.disable()
				$AreaSelection/WeaponRight/ButtonPrompt.disable()
			else:
				$AreaSelection/WeaponLeft/ButtonPrompt.enable()
				$AreaSelection/WeaponRight/ButtonPrompt.enable()
			
			$Anim.play_backwards("ToggleCustomization")
			change_section("Selection")
			yield($Anim, "animation_finished")
	
	yield(get_tree().create_timer(0.1), "timeout")
	can_input = true

func input_cooldown():
	yield(get_tree().create_timer(0.1), "timeout")
	can_input = true
