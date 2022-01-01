extends Node

export (bool) var give_money = false


func _ready():
	if give_money:
		PlayerInfo.change_currency(99999)
