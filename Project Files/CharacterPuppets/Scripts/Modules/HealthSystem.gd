extends Node2D

signal Hurt
signal Dead
signal Healed

signal Knockback
signal KnockbackEnded

var active = true
var controller
var move_module

export (int) var health_max #The most health the character can have
onready var health_current = health_max #The current health of the character

var regen_amount = 0 #The amount that's regenerated
var regen_rate = 0.1 #How fast the health is regenerated
var regen_timer = null

func _ready():
	controller = get_parent().get_parent()
	for module in controller.get_node("Modules").get_children():
		if "Move" in module.name:
			move_module = module
	
	if regen_amount > 0: #Sets up the timer for health regeneration if being used
		controller.setup_timer(regen_timer, regen_rate, false, controller, 
		"modify_stat", [health_current, health_max, regen_amount], "HealthRegenTimer")

func change_health_max(_new_max):
	health_max = _new_max
	heal(0)

#This handles damaging the character
func take_damage(damage = 0, knockback_power = 0, knockback_duration = 1, damage_pos = Vector2()):
	if not active:
		return
	
	var active_mods = []
	var ship_manager = get_parent().get_parent().get_node("ShipManager")
	var frame
	
	if ship_manager != null:
		for part in ship_manager.get_node("Frame").get_children():
			if part.visible:
				frame = part
				break
	
	if frame != null:
		for mod in frame.get_node("Modules").get_children():
			if mod.equipped:
				active_mods.append(mod)
	
	for mod in active_mods:
		match mod.name:
			"Ghost Frame":
				if mod.ability_active:
					return
				else:
					var rand_num = randi()%10
					if rand_num <= 8:
						mod.ghost_chance_activated()
						return
	
	emit_signal("Hurt")
	#Reduce the current health with the modify stat method
	health_current = clamp(health_current - damage, 0, health_max)
	var damage_direction = controller.global_position - damage_pos#This just makes it easier to handle the direction the character is being damaged from
	if damage_pos.x == 0: damage_direction.x = 0
	if damage_pos.y == 0: damage_direction.y = 0
	
	#We take the global position of the character and subtract it from the damage
	#Then we limit it so it can only be right or left at 1 or -1
	var primary_direction
	
	if abs(damage_direction.x) > abs(damage_direction.y):
		primary_direction = "X"
	else:
		primary_direction = "Y"
	damage_direction.x = clamp(damage_direction.x, -1, 1)
	damage_direction.y = clamp(damage_direction.y, -1, 1)
	
	match primary_direction:
		"X":
			damage_direction.y *= 0.05
		"Y":
			damage_direction.x *= 0.05
	
	if move_module != null:
		move_module.knockback(-damage_direction * knockback_power, knockback_duration) #Then set the horizontal velocity to damage jump's value times the direction which knocks us back
		if controller.is_in_group("AI"):
			move_module.move(true)
	
	if health_current == 0:
		emit_signal("Dead")
		disable()

func heal(_amount):
	if not active: return
	health_current = clamp(health_current + _amount, 0, health_max)
	
	emit_signal("Healed")


func disable():
	$Hitbox/AreaCollider.set_deferred("disabled", true)
	active = false


