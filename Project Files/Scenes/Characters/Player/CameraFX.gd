extends Node

onready var cam = get_parent().get_parent().get_parent().get_parent().get_node("CamRig/Anim")

func play_effect(_effect):
	cam.play(_effect)
