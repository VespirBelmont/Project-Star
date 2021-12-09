extends Node2D

var active = false
var can_input = true

var current_menu = "Close"
var focused_area = ""
var focused_part = ""

var option_max = 0
var option_current = 0

var sub_option_max = 0
var sub_option_current = 0

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
			change_menu("AreaMap")
			set_process(true)
		
		false:
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
			
		"ColorSelect":
			for button in $ColorSelect/Buttons.get_children():
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
			revert_to_equipped()
			
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
			
			var ship_visual = get_parent().get_node("ShipManager")
			if ship_visual.wing_check():
				if not $AreaMap/Options/WeaponLeft.available:
					$AreaMap/Options/WeaponLeft.available = true
					$AreaMap/Options/WeaponRight.available = true
				
			else:
				if $AreaMap/Options/WeaponLeft.available:
					$AreaMap/Options/WeaponLeft.available = false
					$AreaMap/Options/WeaponRight.available = false
			
			option_max = 3
			focused_area = ""
			hide_ship_areas()
			
			for button in $AreaMap/Buttons.get_children():
				button.enable()
		
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
			
			var part = $VisualManager_Preview.get_part(focused_area)
			option_max = $ColorSelect/ColorList.get_child_count() - 1
			option_current = 0
			
			sub_option_max = part.get_detail_count()
			sub_option_current = 1
			update_color(1)
			
			
			for button in $ColorSelect/Buttons.get_children():
				button.enable()
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
		
		"ColorSelect":
			color_selection_controls()

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
	
	var dir = 0
	
	if next_item:
		option_current += 1
		dir = 1
	if prev_item:
		option_current -= 1
		dir = -1
	clamp_options()
	
	var part = $PartSelect/PartList.get_node(focused_area).get_child(option_current)
	
	var loop_count = option_current
	if part.unlocked == false:
		for _part in $PartSelect/PartList.get_node(focused_area).get_child_count()-1:
			var check_part = $PartSelect/PartList.get_node(focused_area).get_child(option_current)
			
			if not check_part.unlocked:
				option_current += dir
				clamp_options()
			
			if check_part.unlocked:
				break;
	
	var part_node = $PartSelect/PartList.get_node(focused_area).get_child(option_current)
	
	if part_node == null: return
	
	$VisualManager_Preview.update_part(focused_area, part_node.name)
	
	update_part_info(part_node)
	
	if interact:
		interact_with_part()


func color_selection_controls():
	var prev_detail = Input.is_action_just_pressed("Option_1")
	var next_color = Input.is_action_just_pressed("Option_2")
	var next_detail = Input.is_action_just_pressed("Option_3")
	var prev_color = Input.is_action_just_pressed("Option_4")
	var interact = Input.is_action_just_pressed("Interact")
	
	var last_item = option_current
	var dir = 1
	
	if next_detail:
		sub_option_current += 1
		dir = 1
	if prev_detail:
		sub_option_current -= 1
		dir = -1
	clamp_sub_options()
	
	if next_color:
		option_current += 1
		dir = 1
	if prev_color:
		option_current -= 1
		dir = -1
	clamp_options()
	
	if option_current != last_item:
		update_color(dir)
	
	if interact:
		change_color()

func change_color():
	var color = Color()
	var color_node = $ColorSelect/ColorList.get_child(option_current)
	
	color = color_node.color
	
	$VisualManager_Preview.update_color(focused_area, sub_option_current, color)
	var ship_visual = get_parent().get_node("ShipManager")
	ship_visual.update_color(focused_area, sub_option_current, color)

func update_color(_dir):
	var area = focused_area
	var part = focused_part
	var color = $ColorSelect/ColorList.get_child(option_current)
	
	var loop_count = option_current
	if color.unlocked == false:
		for _color in $ColorSelect/ColorList.get_child_count():
			var focused_color = $ColorSelect/ColorList.get_child(loop_count)
			if not focused_color.unlocked:
				loop_count += _dir
			
			if focused_color.unlocked:
				option_current = loop_count
				break;
			
			clamp_options()
	
	$ColorSelect/Information/ColorName.text = color.name
	$VisualManager_Preview.update_color(focused_area, sub_option_current, color.color)

func module_selection_controls():
	var next_item = Input.is_action_just_pressed("Option_3")
	var prev_item = Input.is_action_just_pressed("Option_1")
	
	if next_item:
		option_current += 1
	if prev_item:
		option_current -= 1
	clamp_options()


func update_part_info(part_node):
	$PartSelect/Information/PartName.text = part_node.name
	$PartSelect/Information/Lore/LoreLabel.text = part_node.lore 
	
	$PartSelect/Information/Stats/Health/MeterProgress.value = part_node.health_mod
	$PartSelect/Information/Stats/Speed/MeterProgress.value = part_node.speed_mod
	$PartSelect/Information/Stats/Damage/MeterProgress.value = part_node.damage_mod
	
	if part_node.purchased:
		$PartSelect/Information/EquipPrompt/OptionLabel.text = "Equip"
		$PartSelect/Information/EquipPrompt/Cost.hide()
	else:
		$PartSelect/Information/EquipPrompt/OptionLabel.text = "Purchase"
		$PartSelect/Information/EquipPrompt/Cost/AmountLabel.text = str(part_node.cost)
		$PartSelect/Information/EquipPrompt/Cost.show()
	
	if part_node.equipped:
		$PartSelect/Information/EquipPrompt/OptionLabel.text = "Equipped"
	
	if not part_node.repaired:
		$PartSelect/Information/EquipPrompt/OptionLabel.text = "Repair"
		$PartSelect/Information/EquipPrompt/Cost/AmountLabel.text = str(part_node.repair_cost)
		$PartSelect/Information/EquipPrompt/Cost.show()


func interact_with_part():
	if current_menu != "PartSelect" or not can_input: 
		return
	can_input = false
	
	var area = $PartSelect/PartList.get_node(focused_area)
	var part_node = area.get_child(option_current)
	
	if part_node.purchased and part_node.repaired:
		$Sounds/Equipped.play()
		var ship_visual = get_parent().get_node("ShipManager")
		ship_visual.update_part(focused_area, part_node.name)
		
		for part in $PartSelect/PartList.get_node(focused_area).get_children():
			part.equipped = false
		part_node.equipped = true
	elif part_node.repaired:
		if PlayerInfo.player_currency >= part_node.cost:
			PlayerInfo.change_currency(-part_node.cost)
			part_node.purchased = true
			$Sounds/Purchased.play()
		else:
			$Sounds/CouldntPurchase.play()
	
	if not part_node.repaired:
		if PlayerInfo.player_currency >= part_node.repair_cost:
			PlayerInfo.change_currency(-part_node.repair_cost)
			part_node.repaired = true
			$Sounds/Purchased.play()
		else:
			$Sounds/CouldntPurchase.play()
	
	update_part_info(part_node)
	
	input_cooldown()

func input_cooldown():
	yield(get_tree().create_timer(0.1), "timeout")
	can_input = true

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
			
			revert_color("Frame", frame.name)
			break
		child_counter += 1
	
	child_counter = 0
	
	
	for wing in $PartSelect/PartList/Wings.get_children():
		if wing.equipped:
			$VisualManager_Preview.update_part("Wings", wing.name)
			
			revert_color("Wings", wing.name)
			break
		child_counter += 1
		if child_counter == $PartSelect/PartList/Wings.get_child_count()-1: 
			$VisualManager_Preview.unequip_all("Wings")
	
	child_counter = 0
	
	for weapon_l in $PartSelect/PartList/WeaponLeft.get_children():
		if weapon_l.equipped:
			$VisualManager_Preview.update_part("WeaponLeft", weapon_l.name)
			
			#revert_color("WeaponLeft", weapon_l.name)
			break
		child_counter += 1
		
		if child_counter == $PartSelect/PartList/WeaponLeft.get_child_count()-1: 
			$VisualManager_Preview.unequip_all("WeaponLeft")
	
	child_counter = 0
	
	for weapon_r in $PartSelect/PartList/WeaponRight.get_children():
		if weapon_r.equipped:
			$VisualManager_Preview.update_part("WeaponRight", weapon_r.name)
			
			#revert_color("WeaponRight", weapon_r.name)
			break
		child_counter += 1
		
		if child_counter == $PartSelect/PartList/WeaponRight.get_child_count()-1: 
			$VisualManager_Preview.unequip_all("WeaponRight")

func revert_color(revert_area, revert_part):
	var ship_visual = get_parent().get_node("ShipManager")
	
	for detail in ship_visual.get_node(revert_area).get_node(revert_part).get_node("GameplaySprite").get_children():
		if "Detail" in detail.name:
			for sprite in detail.get_children():
				if sprite is Sprite:
					var target_color = sprite.modulate
					
					for _detail in $VisualManager_Preview.get_node(revert_area).get_node(revert_part).get_node("PreviewSprite").get_children():
						if _detail.name == detail.name:
							for _sprite in _detail.get_children():
								if _sprite.name == sprite.name:
									_sprite.modulate = target_color

func go_back():
	match current_menu:
		"AreaSelect":
			change_menu("Close")
		
		"PartSelect":
			change_menu("AreaMap")
			yield($Anim, "animation_finished")
		
		"ColorSelect":
			change_menu("AreaMap")
			yield($Anim, "animation_finished")

func clamp_options():
	if option_current < 0:
		option_current = option_max
	if option_current > option_max:
		option_current = 0

func clamp_sub_options():
	if sub_option_current < 1:
		sub_option_current = sub_option_max
	if sub_option_current > sub_option_max:
		sub_option_current = 1
