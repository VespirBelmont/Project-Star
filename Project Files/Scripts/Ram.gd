extends Area2D

export (int) var ram_damage = 2
export (int) var self_damage = 1
export (int) var ram_protection = 0

export (String) var target = "Enemy"

var module_equipped


func modifier_check():
	var ship_manager = get_parent().get_node("ShipManager")
	var current_frame
	
	for frame in ship_manager.get_node("Frame").get_children():
		if frame.visible:
			current_frame = frame
			break
	
	for mod in current_frame.get_node("Modules").get_children():
		if mod.equipped:
			module_equipped = mod
			break
	

func rammed_entity(body):
	modifier_check()
	
	if body == get_parent(): return
	var knockback = Vector2()
	var knockback_pos = get_parent().get_node("Modules/InstantMoveSystem").velocity
	knockback = knockback_pos * 2
	knockback_pos.x = clamp(knockback_pos.x, -1, 1)
	knockback_pos.y = clamp(knockback_pos.y, -1, 1)
	
	var final_ram_damage = ram_damage
	var final_self_damage = self_damage
	
	if is_instance_valid(module_equipped):
		match module_equipped.name:
			"Ram Buster":
				if module_equipped.ability_active:
					final_ram_damage *= 2
				final_self_damage = final_ram_damage * int(0.5)
	
	
	if body.is_in_group(target):
		body.get_node("Modules/HealthSystem").take_damage(final_ram_damage, -knockback, 0.4, knockback_pos)
		self.get_parent().get_node("Modules/HealthSystem").take_damage(final_self_damage, knockback, 0.4, knockback_pos)



