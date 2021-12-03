extends Node2D

var active = false
var can_input = true

var current_menu = "Close"
var focused_area = ""
var focused_part = ""

var option_max = 0
var option_current = 0


func toggle():
	if not can_input: return
	can_input = false
	
	if active:
		active = false
	else:
		active = true
	print(active)
	match active:
		true:
			get_tree().paused = true
			change_menu("AreaMap")
			set_process(true)
		
		false:
			print("Close")
			change_menu("Close")
	
	yield(get_tree().create_timer(0.1), "timeout")
	can_input = true


func change_menu(_new_menu):
	match current_menu:
		"AreaMap":
			for button in $AreaMap/Buttons.get_children():
				button.disable()
		"PartSelect":
			for button in $PartSelect/Buttons.get_children():
				button.disable()
	
	
	match _new_menu:
		"Close":
			set_process(false)
			match current_menu:
				"AreaMap":
					for button in $AreaMap/Buttons.get_children():
						button.disable()
				
				"PartSelect":
					$Anim.play_backwards("ToggleCustomization")
					yield($Anim, "animation_finished")
				
				"ColorSelect":
					$Anim.play_backwards("ToggleCustomization")
					yield($Anim, "animation_finished")
				
				"ModuleSelect":
					$Anim.play_backwards("ToggleCustomization")
					yield($Anim, "animation_finished")
			
			
			$Anim.play_backwards("ToggleSystem")
			yield($Anim, "animation_finished")
			get_tree().paused = false
			
			option_current = 0
			hide_ship_areas()
		
		"AreaMap":
			match current_menu:
				"Close":
					$Anim.play("ToggleSystem")
					yield($Anim, "animation_finished")
				
				"PartSelect":
					$Anim.play_backwards("TogglePartSelect")
					yield($Anim, "animation_finished")
				
				"ColorSelect":
					$Anim.play_backwards("ToggleColorSelect")
					yield($Anim, "animation_finished")
				
				"ModuleSelect":
					$Anim.play_backwards("ToggleModuleSelect")
					yield($Anim, "animation_finished")
			
			for wing in $PartSelect/PartList/Wings.get_children():
				if wing.equipped:
					if not $AreaMap/Options/WeaponLeft.available:
						$AreaMap/Options/WeaponLeft.available = true
						$AreaMap/Options/WeaponRight.available = true
						break
				
				if $AreaMap/Options/WeaponLeft.available:
					$AreaMap/Options/WeaponLeft.available = false
					$AreaMap/Options/WeaponRight.available = false
			
			option_max = 3
			focused_area = ""
			
			for button in $AreaMap/Buttons.get_children():
				button.enable()
			
			revert_to_equipped()
		
		"PartSelect":
			var area = $AreaMap/Options.get_child(option_current).name
			focused_area = area
			
			option_max = $PartSelect/PartList.get_node(area).get_child_count()-1
			option_current = 0
			
			$Anim.play("TogglePartSelect")
			yield($Anim, "animation_finished")
			
			for button in $PartSelect/Buttons.get_children():
				button.enable()
		
		"ColorSelect":
			var area = $AreaMap/Options.get_child(option_current).name
			focused_area = area
			$ColorSelect.update_area(focused_area)
			
			$Anim.play("ToggleColorSelect")
			yield($Anim, "animation_finished")
		
		"ModuleSelect":
			var area = $AreaMap/Options.get_child(option_current).name
			focused_area = area
			$ModuleSelect.update_area(focused_area)
			
			$Anim.play("ToggleModuleSelect")
			yield($Anim, "animation_finished")
	
	current_menu = _new_menu
	input_cooldown()


func _process(delta):
	match current_menu:
		"AreaMap":
			area_map_controls()
		
		"PartSelect":
			part_selection_controls()

func area_map_controls():
	var options = $AreaMap/Options
	
	var next_item = Input.is_action_just_pressed("Option_3")
	var prev_item = Input.is_action_just_pressed("Option_1")
	
	var last_option = option_current
	var method = ""
	
	if next_item:
		option_current += 1
		method = "Add"
	if prev_item:
		option_current -= 1
		method = "Subtract"
	clamp_options()
	
	if not options.get_child(option_current).available:
		for opt in option_max:
			if options.get_child(option_current).available:
				break
			else:
				if method == "Add":
					option_current += 1
				else:
					option_current -= 1
				clamp_options()
	
	if last_option != option_current:
		hide_ship_areas()
	
	if last_option != option_current or not options.get_child(option_current).visible:
		options.get_child(option_current).get_node("Anim").play("Toggle")
	
	if last_option == option_current: return
	
	if options.get_child(option_current).available:
		for butt in $AreaMap/Buttons.get_children():
			butt.enable()
	else:
		for butt in $AreaMap/Buttons.get_children():
			butt.disable()


func part_selection_controls():
	var next_item = Input.is_action_just_pressed("Option_2")
	var prev_item = Input.is_action_just_pressed("Option_4")
	var interact = Input.is_action_just_pressed("Interact")
	
	if next_item:
		option_current += 1
	if prev_item:
		option_current -= 1

	
	clamp_options()
	
	var part_node = $PartSelect/PartList.get_node(focused_area).get_child(option_current)
	
	if part_node == null: return
	
	$VisualManager_Preview.update_part(focused_area, part_node.name)
	
	update_part_info(part_node.name, part_node.lore, 
				part_node.speed_mod, part_node.health_mod, 
				part_node.damage_mod,
				part_node.cost,
				part_node.purchased,
				part_node.equipped
				)
	
	if interact:
		interact_with_part()


func color_selection_controls():
	var next_item = Input.is_action_just_pressed("Option_3")
	var prev_item = Input.is_action_just_pressed("Option_1")
	
	if next_item:
		option_current += 1
	if prev_item:
		option_current -= 1
	clamp_options()

func module_selection_controls():
	var next_item = Input.is_action_just_pressed("Option_3")
	var prev_item = Input.is_action_just_pressed("Option_1")
	
	if next_item:
		option_current += 1
	if prev_item:
		option_current -= 1
	clamp_options()


func update_part_info(_part_name, _lore, _speed, _health, _damage, _cost, _purchased, _equipped):
	$PartSelect/Information/PartName.text = _part_name
	$PartSelect/Information/Lore/LoreLabel.text = _lore
	
	$PartSelect/Information/Stats/Health/MeterProgress.value = _health
	$PartSelect/Information/Stats/Speed/MeterProgress.value = _speed
	$PartSelect/Information/Stats/Damage/MeterProgress.value = _damage
	
	$PartSelect/Information/EquipPrompt/Cost/AmountLabel.text = str(_cost)
	
	if _purchased:
		$PartSelect/Information/EquipPrompt/OptionLabel.text = "Equip"
		$PartSelect/Information/EquipPrompt/Cost.hide()
	else:
		$PartSelect/Information/EquipPrompt/OptionLabel.text = "Purchase"
		$PartSelect/Information/EquipPrompt/Cost.show()
	
	if _equipped:
		$PartSelect/Information/EquipPrompt/OptionLabel.text = "Equipped"


func interact_with_part():
	print(can_input)
	if focused_area == "" or not can_input: 
		print("Can't interact")
		return
	can_input = false
	
	print("Interact")
	
	var area = $PartSelect/PartList.get_node(focused_area)
	var part_node = area.get_child(option_current)
	
	if part_node.purchased:
		$Sounds/Equipped.play()
		var ship_visual = get_parent().get_node("ShipManager")
		ship_visual.update_part(focused_area, part_node.name)
		
		for part in $PartSelect/PartList.get_node(focused_area).get_children():
			part.equipped = false
		part_node.equipped = true
	else:
		if PlayerInfo.player_currency >= part_node.cost:
			PlayerInfo.change_currency(-part_node.cost)
			part_node.purchased = true
			$Sounds/Purchased.play()
		else:
			$Sounds/CouldntPurchase.play()
	
	update_part_info(part_node.name, part_node.lore, 
				part_node.speed_mod, part_node.health_mod, 
				part_node.damage_mod,
				part_node.cost,
				part_node.purchased,
				part_node.equipped
				)
	
	input_cooldown()

func input_cooldown():
	yield(get_tree().create_timer(0.1), "timeout")
	can_input = true
	print("Can input")

func hide_ship_areas():
	var options = $AreaMap/Options
	
	for opt in options.get_children():
		if opt.visible:
			opt.get_node("Anim").play_backwards("Toggle")

func revert_to_equipped():
	var child_counter = 0
	
	for frame in $PartSelect/PartList/Frame.get_children():
		if frame.equipped:
			$VisualManager_Preview.update_part("Frame", frame.name)
			break
		child_counter += 1
	
	child_counter = 0
	
	for wing in $PartSelect/PartList/Wings.get_children():
		if wing.equipped:
			$VisualManager_Preview.update_part("Wings", wing.name)
			break
		child_counter += 1
		if child_counter == $PartSelect/PartList/Wings.get_child_count()-1: 
			$VisualManager_Preview.unequip_all("Wings")
	
	child_counter = 0
	
	for weapon_l in $PartSelect/PartList/WeaponLeft.get_children():
		if weapon_l.equipped:
			$VisualManager_Preview.update_part("WeaponLeft", weapon_l.name)
			break
		child_counter += 1
		
		if child_counter == $PartSelect/PartList/WeaponLeft.get_child_count()-1: 
			$VisualManager_Preview.unequip_all("WeaponLeft")
	
	child_counter = 0
	
	for weapon_r in $PartSelect/PartList/WeaponRight.get_children():
		if weapon_r.equipped:
			$VisualManager_Preview.update_part("WeaponRight", weapon_r.name)
			break
		child_counter += 1
		
		if child_counter == $PartSelect/PartList/WeaponRight.get_child_count()-1: 
			$VisualManager_Preview.unequip_all("WeaponRight")

func go_back():
	match current_menu:
		"AreaSelect":
			change_menu("Close")
		
		"PartSelect":
			change_menu("AreaMap")
			yield($Anim, "animation_finished")

func clamp_options():
	if option_current < 0:
		option_current = option_max
	if option_current > option_max:
		option_current = 0


