extends Node

export var lore = ""

export var health_mod = 0
export var speed_mod = 0
export var damage_mod = 0

export (int) var cost = 1

export (bool) var purchased = false
export (bool) var equipped = false
export (bool) var can_unequip = false

export (PackedScene) var visual
