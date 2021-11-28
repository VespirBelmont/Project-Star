extends Node2D

var part_min = 0
var part_max = 0
var current_part = 0
var current_area = ""

var can_input = true

func update_area(_area):
	current_area = _area
	part_max = $PartList.get_node(_area).get_child_count() -1
	current_part = 0
	
	select_part(0)


func select_part(_direction):
	if current_area == "" or not can_input: return
	can_input = false
	
	current_part += _direction
	
	
	if current_part < 0:
		current_part = part_max
	
	if current_part > part_max:
		current_part = 0
	
	var part_node = $PartList.get_node(current_area).get_child(current_part)
	
	if part_node == null: return
	
	get_parent().get_node("VisualManager_Preview").update_part(current_area, part_node.name)
	
	update_info(part_node.name, part_node.lore, 
				part_node.speed_mod, part_node.health_mod, 
				part_node.damage_mod,
				part_node.cost,
				part_node.purchased,
				part_node.equipped
				)
	
	input_cooldown()

func update_info(_part_name, _lore, _speed, _health, _damage, _cost, _purchased, _equipped):
	
	$Information/PartName.text = _part_name
	$Information/Lore/LoreLabel.text = _lore
	
	$Information/Stats/Health/MeterProgress.value = _health
	$Information/Stats/Speed/MeterProgress.value = _speed
	$Information/Stats/Damage/MeterProgress.value = _damage
	
	$Information/EquipPrompt/Cost/AmountLabel.text = str(_cost)
	
	if _purchased:
		$Information/EquipPrompt/OptionLabel.text = "Equip"
		$Information/EquipPrompt/Cost.hide()
	else:
		$Information/EquipPrompt/OptionLabel.text = "Purchase"
		$Information/EquipPrompt/Cost.show()
	
	if _equipped:
		$Information/EquipPrompt/OptionLabel.text = "Equipped"

func interact_with_part():
	if current_area == "" or not can_input: return
	can_input = false
	
	var part_node = $PartList.get_node(current_area).get_child(current_part)
	
	if part_node.purchased:
		$Sounds/Equipped.play()
		var ship_visual = get_parent().get_parent().get_node("VisualManager")
		ship_visual.update_part(current_area, part_node.name)
		
		for part in $PartList.get_node(current_area).get_children():
			part.equipped = false
		part_node.equipped = true
	else:
		if PlayerInfo.player_currency >= part_node.cost:
			PlayerInfo.change_currency(-part_node.cost)
			part_node.purchased = true
			$Sounds/Purchased.play()
		else:
			$Sounds/CouldntPurchase.play()
	
	update_info(part_node.name, part_node.lore, 
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

func revert_to_equipped():
	var child_counter = 0
	
	for frame in $PartList/Frame.get_children():
		if frame.equipped:
			get_parent().get_node("VisualManager_Preview").update_part("Frame", frame.name)
			break
		child_counter += 1
	
	child_counter = 0
	
	for wing in $PartList/Wings.get_children():
		if wing.equipped:
			get_parent().get_node("VisualManager_Preview").update_part("Wings", wing.name)
			break
		child_counter += 1
		if child_counter == $PartList/Wings.get_child_count()-1: 
			get_parent().get_node("VisualManager_Preview").unequip_all("Wings")
	
	child_counter = 0
	
	for weapon_l in $PartList/WeaponLeft.get_children():
		if weapon_l.equipped:
			get_parent().get_node("VisualManager_Preview").update_part("WeaponLeft", weapon_l.name)
			break
		child_counter += 1
		
		if child_counter == $PartList/WeaponLeft.get_child_count()-1: 
			get_parent().get_node("VisualManager_Preview").unequip_all("WeaponLeft")
	
	child_counter = 0
	
	for weapon_r in $PartList/WeaponRight.get_children():
		if weapon_r.equipped:
			get_parent().get_node("VisualManager_Preview").update_part("WeaponRight", weapon_r.name)
			break
		child_counter += 1
		
		if child_counter == $PartList/WeaponRight.get_child_count()-1: 
			get_parent().get_node("VisualManager_Preview").unequip_all("WeaponRight")



