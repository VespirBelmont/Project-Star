extends Control

export (String) var url = ""


func _on_Button_pressed():
	$Sprite/Anim.play("Pressed")
	yield(get_tree().create_timer(0.5), "timeout")
	$Sprite/Anim.play("Normal")
	OS.shell_open(url)


func enable():
	$ButtonInput.enable()

func disable():
	$ButtonInput.disable()

