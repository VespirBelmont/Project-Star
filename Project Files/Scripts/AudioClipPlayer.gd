extends AudioStreamPlayer

export (Array, AudioStream) var audio_clips

func play_random():
	self.stream = audio_clips[randi()%audio_clips.size()-1]
	
	self.play()
