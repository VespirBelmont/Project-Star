extends "res://Scripts/CollectableCore.gd"

var currency_options = ["CopperNut", "SilverNut", "CopperBolt", "GoldBolt"]

export var currency_values = {
								"CopperNut": {"CurrencyValue": 1, "Chance": 75},
								"SilverNut": {"CurrencyValue": 5, "Chance": 60},
								"CopperBolt": {"CurrencyValue": 10, "Chance": 45},
								"GoldBolt": {"CurrencyValue": 20, "Chance": 30},
							}

func _ready():
	yield(get_tree().create_timer(0.2), "timeout")
	randomize()
	var chosen_value
	
	for option in currency_options:
		var option_value = currency_values[option].CurrencyValue
		var option_chance = currency_values[option].Chance
		var rand_num = randi()%100
		
		if rand_num <= option_chance:
			chosen_value = option
			value = option_value
	
	if chosen_value == null:
		chosen_value = "CopperNut"
		value = currency_values.CopperNut
	
	
	$DropNode/Sprites.get_node(chosen_value).show()
	
	$DropNode/AreaCollider.set_deferred("disabled", false)
	$DropNode.show()


func add_currency(_body):
	PlayerInfo.change_currency(value)
	$Anim.play("Collected")
	yield($Anim, "animation_finished")
	self.call_deferred("free")


