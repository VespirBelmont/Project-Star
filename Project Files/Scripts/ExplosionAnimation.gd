extends Node2D

func destroy():
	self.call_deferred("free")
