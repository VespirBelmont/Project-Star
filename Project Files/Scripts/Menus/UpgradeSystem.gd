extends Control

var active = false #This tells us if the menu is active
var can_input = true #This tells us whether input can be used or not

var current_menu = "Close" #This is the current menu being looked at
var focused_area = "" #This is the area of the ship that's being edited
var focused_part = "" #This is the specific part of the ship being edited

#These are the primary options used to select items in menus
var option_max = 0 #The maximum an option can be
var option_current = 0 #The current option

#These are optional sub options for extra precision in menus
var sub_option_max = 0 #The maximum a sub option can be
var sub_option_current = 0  #The current sub option

var player_ship #This will be the player's ship node


#VARIABLES END HERE FRIEND!



func _ready():
	#We get the player ship node right away because it's used a lot
	player_ship = get_parent().get_parent().get_parent().get_parent().get_node("Players/P1/ShipManager")

func toggle():
	if not can_input: return
	can_input = false
	
	if active:
		active = false
		$WorkshopMusic.turn_off()
	
	else:
		active = true
		$WorkshopMusic.turn_on()
	
	match active:
		true:
			get_tree().paused = true
			change_menu("AreaMap")
			return  #This avoids the player from spamming open
		
		false:
			change_menu("Close")
			return #This avoids the player from spamming close
	
	yield(get_tree().create_timer(0.1), "timeout")
	can_input = true


func change_menu(_new_menu):
	can_input = false
	
	match current_menu:
		"AreaMap":
			for button in $AreaMap/Buttons.get_children():
				button.disable()
			
			var options = $AreaMap/Options
			for opt in options.get_children():
				opt.get_node("Anim").play("Disable")
		
		"PartSelect":
			for button in $PartSelect/Buttons.get_children():
				button.disable()
			
		"ColorSelect":
			for button in $ColorSelect/Buttons.get_children():
				button.disable()
	
		"ModuleSelect":
			for button in $ModuleSelect/Buttons.get_children():
				button.disable()
	
	match _new_menu:
		"Close":
			set_process(false)
			match current_menu:
				"AreaMap":
					for button in $AreaMap/Buttons.get_children():
						button.disable()
				
				"PartSelect":
					$Anim.play_backwards("TogglePartSelect")
					yield($Anim, "animation_finished")
				
				"ColorSelect":
					$Anim.play_backwards("ToggleColorSelect")
					yield($Anim, "animation_finished")
				
				"ModuleSelect":
					$Anim.play_backwards("ToggleModuleSelect")
					yield($Anim, "animation_finished")
			
			
			$Anim.play_backwards("ToggleSystem")
			yield($Anim, "animation_finished")
			get_tree().paused = false
			
			option_current = 0
			yield(get_tree().create_timer(0.2), "timeout")
			#hide_ship_areas()
		
		"AreaMap":
			revert_to_equipped()
			$AreaMap/Options.get_child(option_current).get_node("Anim").play("Enable")
			
			match current_menu:
				"Close":
					$Anim.play("ToggleSystem")
					
					
					yield($Anim, "animation_finished")
					yield(get_tree().create_timer(0.2), "timeout")
				
				"PartSelect":
					$Anim.play_backwards("TogglePartSelect")
					yield($Anim, "animation_finished")
				
				"ColorSelect":
					$Anim.play_backwards("ToggleColorSelect")
					yield($Anim, "animation_finished")
				
				"ModuleSelect":
					$Anim.play_backwards("ToggleModuleSelect")
					yield($Anim, "animation_finished")
			
			if player_ship.wing_check():
				if not $AreaMap/Options/WeaponLeft.available:
					$AreaMap/Options/WeaponLeft.available = true
					$AreaMap/Options/WeaponRight.available = true
				
			else:
				if $AreaMap/Options/WeaponLeft.available:
					$AreaMap/Options/WeaponLeft.available = false
					$AreaMap/Options/WeaponRight.available = false
			
			option_max = 4
			option_current = 0
			focused_area = ""
			
			for button in $AreaMap/Buttons.get_children():
				button.enable()
			set_process(true)
		
		"PartSelect":
			var area = $AreaMap/Options.get_child(option_current).name
			focused_area = area
			
			option_max = $PartSelect/PartList.get_node(area).get_child_count()-1
			option_current = 0
			
			$Anim.play("TogglePartSelect")
			yield($Anim, "animation_finished")
			
			for button in $PartSelect/Buttons.get_children():
				button.enable()
			
			set_process(true)
		
		"ColorSelect":
			var area = $AreaMap/Options.get_child(option_current).name
			focused_area = area
			
			var part = $ShipPreview.get_part(focused_area)
			option_max = $ColorSelect/ColorList.get_child_count() - 1
			option_current = 0
			
			sub_option_max = part.get_detail_count() - 1
			sub_option_current = 0
			update_color(1)
			
			
			for button in $ColorSelect/Buttons.get_children():
				button.enable()
			$Anim.play("ToggleColorSelect")
			yield($Anim, "animation_finished")
			
			set_process(true)
		
		"ModuleSelect":
			var area = $AreaMap/Options.get_child(option_current).name
			focused_area = area
			
			var part_in_use
			for _part in $PartSelect/PartList.get_node(focused_area).get_children():
				if _part.equipped:
					part_in_use = _part.name
					break
			
			var part = $ModuleSelect/ModuleList.get_node(focused_area).get_node(part_in_use)
			
			option_current = 0
			option_max = part.get_node("Modules").get_child_count()-1
			
			$Anim.play("ToggleModuleSelect")
			yield($Anim, "animation_finished")
			
			for button in $ModuleSelect/Buttons.get_children():
				button.enable()
			
			set_process(true)
	
	current_menu = _new_menu
	input_cooldown()

func area_map_interact():
	if not can_input or current_menu != "AreaMap": return
	can_input = false
	
	var type = $AreaMap/Options.get_child(option_current).name
	if type == "Repair":
		repair()
	else:
		change_menu("PartSelect")
	
	input_cooldown()

func repair():
	var cost = int($AreaMap/Options/Repair/Cost/AmountLabel.text)
	
	if player_ship.get_parent().get_node("Modules/HealthSystem").health_current == player_ship.get_parent().get_node("Modules/HealthSystem").health_max:
		$Sounds/CouldntPurchase.play()
		return
	
	if PlayerInfo.player_currency >= cost:
		player_ship.get_parent().get_node("Modules/HealthSystem").heal(1)
		PlayerInfo.change_currency(-cost)
		$Sounds/Purchased.play()
	else:
		$Sounds/CouldntPurchase.play()

func _process(_delta):
	match current_menu:
		"AreaMap":
			if can_input:
				area_map_controls()
		
		"PartSelect":
			if can_input:
				part_selection_controls()
		
		"ColorSelect":
			if can_input:
				color_selection_controls()
		
		"ModuleSelect":
			if can_input:
				module_selection_controls()

func area_map_controls():
	var options = $AreaMap/Options
	
	var next_item = Input.is_action_just_pressed("Option_3")
	var prev_item = Input.is_action_just_pressed("Option_1")
	
	var last_option = option_current
	var method = ""
	
	var highlighted_area = $AreaMap/Options.get_child(option_current).name
	
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
	
	var part_in_use 
	if options.get_child(option_current).name != "Repair" and highlighted_area != "Repair":
		for part in $PartSelect/PartList.get_node(highlighted_area).get_children():
			if part.equipped:
				part_in_use = part
				break
	
	if part_in_use == null:
		$AreaMap/Buttons/ColorSelect.disable()
		$AreaMap/Buttons/ModuleSelect.disable()
	else:
		$AreaMap/Buttons/ColorSelect.enable()
		$AreaMap/Buttons/ModuleSelect.enable()
	
	if last_option != option_current or not options.get_child(option_current).visible:
		options.get_child(last_option).get_node("Anim").play("Disable")
		options.get_child(option_current).get_node("Anim").play("Enable")
		
		if options.get_child(option_current).name != "Repair":
			$AreaMap/Buttons/PartSelect/OptionLabel.text = "Parts"
		if options.get_child(option_current).name == "Repair":
			$AreaMap/Buttons/PartSelect/OptionLabel.text = "Repair"
	
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
	
	$ShipPreview.update_part(focused_area, part_node.name)
	
	update_part_info(part_node)
	
	if interact:
		interact_with_part()


func color_selection_controls():
	var prev_detail = Input.is_action_just_pressed("Option_1")
	var next_color = Input.is_action_just_pressed("Option_2")
	var next_detail = Input.is_action_just_pressed("Option_3")
	var prev_color = Input.is_action_just_pressed("Option_4")
	var interact = Input.is_action_just_pressed("Interact")
	
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
	
	update_color(dir)
	
	$ColorSelect/Information/DetailName.text = player_ship.get_part(focused_area).get_node("SpriteList").get_child(sub_option_current).name
	
	if interact:
		change_color()

func change_color():
	var color = Color()
	var color_node = $ColorSelect/ColorList.get_child(option_current)
	
	color = color_node.color
	
	$ShipPreview.update_color(focused_area, sub_option_current, color)
	player_ship.update_color(focused_area, sub_option_current, color)
	$ColorSelect/ChangeColorSound.play()

func update_color(_dir):
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
	$ShipPreview.update_color(focused_area, sub_option_current, color.color)

func module_selection_controls():
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
	
	
	var module
	var part_in_use
	
	for _part in $PartSelect/PartList.get_node(focused_area).get_children():
		if _part.equipped:
			part_in_use = _part
			break
	
	for _part in $ModuleSelect/ModuleList.get_node(focused_area).get_children():
		if _part.name == part_in_use.name:
			module = _part.get_node("Modules").get_child(option_current)
	
	if module.unlocked == false:
		for _mod in $ModuleSelect/ModuleList.get_node(focused_area).get_node(part_in_use.name).get_child_count()-1:
			var check_mod = $ModuleSelect/ModuleList.get_node(focused_area).get_node(part_in_use.name).get_node("Modules").get_child(option_current)
			
			if not check_mod.unlocked:
				option_current += dir
				clamp_options()
			
			if check_mod.unlocked:
				break;
	
	var module_node = $ModuleSelect/ModuleList.get_node(focused_area).get_node(part_in_use.name).get_node("Modules").get_child(option_current)
	
	if module_node == null: return
	
	update_module_info(module_node)
	
	if interact:
		interact_with_module()


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

func update_module_info(module_node):
	$ModuleSelect/Information/ModuleName.text = module_node.name
	$ModuleSelect/Information/Description/Label.text = module_node.description 
	
	if module_node.purchased and module_node.equipped == false:
		$ModuleSelect/Information/EquipPrompt/OptionLabel.text = "Equip"
		$ModuleSelect/Information/EquipPrompt/Cost.hide()
	else:
		$ModuleSelect/Information/EquipPrompt/OptionLabel.text = "Purchase"
		$ModuleSelect/Information/EquipPrompt/Cost/AmountLabel.text = str(module_node.purchase_cost)
		$ModuleSelect/Information/EquipPrompt/Cost.show()
	
	if module_node.purchased and module_node.equipped == true:
		$ModuleSelect/Information/EquipPrompt/OptionLabel.text = "Unequip"
		$ModuleSelect/Information/EquipPrompt/Cost.hide()

func interact_with_part():
	if current_menu != "PartSelect" or not can_input: 
		return
	can_input = false
	
	var area = $PartSelect/PartList.get_node(focused_area)
	var part_node = area.get_child(option_current)
	
	#Equip a part
	if part_node.purchased and part_node.repaired and not part_node.equipped:
		$PartSelect/EquipSound.play()
		player_ship.update_part(focused_area, part_node.name)
		
		for part in $PartSelect/PartList.get_node(focused_area).get_children():
			part.equipped = false
		part_node.equipped = true
	
	#Unequip a Part
	if part_node.purchased and part_node.repaired and part_node.equipped and part_node.can_unequip:
		#$PartSelect/UnequipSound.play()
		pass
	
	
	if not part_node.purchased and part_node.repaired:
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
			$PartSelect/EquipSound.play()
		else:
			$Sounds/CouldntPurchase.play()
	
	update_part_info(part_node)
	
	input_cooldown()

func interact_with_module():
	if current_menu != "ModuleSelect" or not can_input: 
		return
	can_input = false
	
	
	var part_in_use
	for _part in $PartSelect/PartList.get_node(focused_area).get_children():
		if _part.equipped:
			part_in_use = _part
			break
	
	var module_node = $ModuleSelect/ModuleList.get_node(focused_area).get_node(part_in_use.name).get_node("Modules").get_child(option_current)
	
	if module_node.purchased:
		if module_node.equipped == false:
			$Sounds/Equipped.play()
			module_node.equipped = true
			player_ship.update_module(focused_area, part_in_use.name, module_node.name, true)
		else:
			module_node.equipped = false
			player_ship.update_module(focused_area, part_in_use.name, module_node.name, false)
	else:
		if PlayerInfo.player_currency >= module_node.purchase_cost:
			PlayerInfo.change_currency(-module_node.purchase_cost)
			module_node.purchased = true
			$Sounds/Purchased.play()
		else:
			$Sounds/CouldntPurchase.play()
	
	update_module_info(module_node)
	
	input_cooldown()


func unlock_part(part_area, part_name):
	var part = $PartSelect/PartList.get_node(part_area).get_node(part_name)
	
	if part.unlocked:
		part.repaired = true
	else:
		part.unlocked = true


func input_cooldown():
	yield(get_tree().create_timer(0.001), "timeout")
	can_input = true


func revert_to_equipped():
	var child_counter = 0
	
	for frame in $PartSelect/PartList/Frame.get_children():
		if frame.equipped:
			$ShipPreview.update_part("Frame", frame.name)
			
			revert_color("Frame", frame.name)
			break
		child_counter += 1
	
	child_counter = 0
	
	
	for wing in $PartSelect/PartList/Wings.get_children():
		if wing.equipped:
			$ShipPreview.update_part("Wings", wing.name)
			
			revert_color("Wings", wing.name)
			break
		child_counter += 1
		if child_counter == $PartSelect/PartList/Wings.get_child_count()-1: 
			$ShipPreview.unequip_all("Wings")
	
	child_counter = 0
	
	for weapon_l in $PartSelect/PartList/WeaponLeft.get_children():
		if weapon_l.equipped:
			$ShipPreview.update_part("WeaponLeft", weapon_l.name)
			
			#revert_color("WeaponLeft", weapon_l.name)
			break
		child_counter += 1
		
		if child_counter == $PartSelect/PartList/WeaponLeft.get_child_count()-1: 
			$ShipPreview.unequip_all("WeaponLeft")
	
	child_counter = 0
	
	for weapon_r in $PartSelect/PartList/WeaponRight.get_children():
		if weapon_r.equipped:
			$ShipPreview.update_part("WeaponRight", weapon_r.name)
			
			#revert_color("WeaponRight", weapon_r.name)
			break
		child_counter += 1
		
		if child_counter == $PartSelect/PartList/WeaponRight.get_child_count()-1: 
			$ShipPreview.unequip_all("WeaponRight")

func revert_color(revert_area, revert_part):
	for detail in player_ship.get_node(revert_area).get_node(revert_part).get_node("SpriteList").get_children():
		for sprite in detail.get_children():
			if sprite is Sprite:
				var target_color = sprite.modulate
				
				for _detail in $ShipPreview.get_node(revert_area).get_node(revert_part).get_node("SpriteList").get_children():
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
		
		"ColorSelect":
			change_menu("AreaMap")
		
		"ModuleSelect":
			change_menu("AreaMap")

func clamp_options():
	if option_current < 0:
		option_current = option_max
	if option_current > option_max:
		option_current = 0

func clamp_sub_options():
	if sub_option_current < 0:
		sub_option_current = sub_option_max
	if sub_option_current > sub_option_max:
		sub_option_current = 0

