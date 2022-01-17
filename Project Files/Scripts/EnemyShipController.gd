extends "res://Scripts/Ship Scripts/ShipController.gd"

signal enemy_activated
signal Dead

export (PackedScene) var currency_drop
export (PackedScene) var part_drop_node
export (PackedScene) var explosion_effect

var player_node

export (Array, String) var part_drops = []

export var distance_until_delete = 200

export var hazard_drops = {
								
							}

var dropped_loot = false

var active = false
export var drop_rates = {
							"Currency": 70,
							"Part": 20,
							"Hazard": 40
						}

func start_up():
	active = true
	emit_signal("enemy_activated")

func set_state(_state):
	if state == "Dead": return
	
	match _state:
		"Hurt":
			pass
		
		"Dead":
			emit_signal("Dead")
			
			$Modules/HealthSystem.disable()
			$Anim.play("Death")
			var explosion = explosion_effect.instance()
			get_parent().add_child(explosion)
			explosion.global_position = self.global_position
			create_loot()
			yield($Anim, "animation_finished")
			self.hide()
			self.queue_free()
	
	state = _state

func check_if_obsolete():
	var player_pos = PlayerInfo.player_pos.y
	var self_pos = self.global_position.y
	var distance = player_pos - self_pos
	
	
	if distance <= distance_until_delete:
		print("EnemyShipController.gd")
		print("Out of Bounds")
		print("--------------")
		destroy()

func create_loot():
	if dropped_loot: return
	
	dropped_loot = true
	
	var parent = get_parent().get_parent().get_node("LootPool")
	var drop_type
	var drop_node
	
	for drop in drop_rates.keys():
		var chance = drop_rates[drop]
		var rand_num = randi()%100
		
		if rand_num <= chance:
			drop_type = drop
			break
	
	if drop_type == null: return 
	
	match drop_type:
		"Currency":
			drop_node = currency_drop.instance()
		
		"Part":
			drop_node = part_drop_node.instance()
		
		"Hazard":
			pass
	
	if drop_node != null:
		parent.call_deferred("add_child", drop_node)
		drop_node.get_node("DropNode").set_deferred("global_position", self.global_position)
		
		if drop_type == "Part":
			drop_node.call_deferred("setup", part_drops)


