extends AudioStreamPlayer

export (float) var target_volume


func turn_on():
	self.play()
	
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "volume_db", self.volume_db, target_volume, 5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween, "tween_completed")
	tween.queue_free()

func turn_off():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "volume_db", self.volume_db, -50, 5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
	yield(tween, "tween_completed")
	self.stop()
	tween.queue_free()
