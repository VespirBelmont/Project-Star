extends Timer

export (float) var min_time
export (float) var max_time

func start_up():
	self.wait_time = rand_range(min_time, max_time)
	
	yield(get_tree().create_timer(rand_range(0.2, 1)), "timeout")
	self.start()
