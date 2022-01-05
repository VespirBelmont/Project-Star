extends Node2D

signal EquippedMod
signal UnequippedMod

export (bool) var equipped = false

func equip():
	equipped = true
	emit_signal("EquippedMod")

func unequip():
	equipped = false
	emit_signal("UnequippedMod")

