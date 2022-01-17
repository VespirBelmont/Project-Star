extends Area2D

func destroyed():
	call_deferred("free")
