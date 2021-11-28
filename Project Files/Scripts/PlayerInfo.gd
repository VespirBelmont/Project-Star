extends Node

signal CurrencyUpdated

var player_currency = 0


func change_currency(_amount):
	player_currency += _amount
	emit_signal("CurrencyUpdated", player_currency)
