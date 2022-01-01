extends Node

signal CurrencyUpdated

var player_currency = 0
var player_pos = Vector2()

func change_currency(_amount):
	if not _amount is int: 
		print("PlayerInfo.gd | CRASH | Amount isn't an int: ", _amount)
		return
	
	player_currency += _amount
	emit_signal("CurrencyUpdated", player_currency)
