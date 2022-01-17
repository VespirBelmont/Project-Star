extends Label

export (Array, String) var messages

var message_file = "res://RandomMessages.txt"

func randomize_message():
	$Anim.play_backwards("Toggle")
	yield($Anim, "animation_finished")
	self.text = messages[randi()%(messages.size()-1)]
	$Anim.play("Toggle")
