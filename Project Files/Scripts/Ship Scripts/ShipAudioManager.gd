extends Node


func play_sound(_sound_name):
	self.get_node(_sound_name).play()


func play_random_sound(_sound_name):
	self.get_node(_sound_name).play_random()

