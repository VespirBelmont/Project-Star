extends KinematicBody2D

var move_module
var health_module

var state = "Idle" #This is the main state the character is in [Explained in Documentation Document]
var state_mod = "None" #This will change how a state behaves. [Explained in Documentation Document]
var next_anim = "Idle" #This will tell what animation should be played next



func _ready():
	for module in $Modules.get_children():
		if "Move" in module.name:
			move_module = module
		if "Health" in module.name:
			health_module = module


#This creates and sets up a timer procedurally since they're used a few times and makes for an easier setup.
func setup_timer(timer, wait_time, one_shot, connect_obj, connect_method, connect_parameters, timer_name):
	timer = Timer.new() #Create a new Timer node
	add_child(timer) #Add the timer node to the tscn
	timer.name = timer_name #Set the timer name to the given name
	
	timer.wait_time = wait_time #Set the timer wait time to the given time
	timer.one_shot = one_shot #Set the timer one shot to the given value
	
	#Connect the timer to the object and method with the given parameters
	timer.connect("timeout", connect_obj, connect_method, connect_parameters)
	timer.start() #Start the timer


#This handles playing the right animation
func update_animation():
	if $CharAnim.has_animation(next_anim): #Checks to see if the animation player has the wanted animation [This avoids a crash]
		if $CharAnim.current_animation != next_anim: #Then it makes sure it isn't the current animation so it's not stuck on frame 1
			$CharAnim.play(next_anim) #Then if it passes the checks then play the next animation


#This handles changing stats (health, stamina, etc) with ease and minimal code
func modify_stat(stat, stat_max, stat_change):
	#The given stat we sent is adjusted by the change amount
	#We clamp it between 0 and the stat maximum
	#This way it stays within the numbers we want all within one line of code for any stat we have
	stat = clamp(stat + stat_change, 0, stat_max)


#This function handles using particles when needed. It's a neat way to centralize the usage of particles from other puppet scripts.
func use_particle(particle_type):
	#It matches the type and then sets emitting to true
	#On demand particles
	match particle_type:
		"Dust":
			$Particles/DustParticles.emitting = false #In case it's emitting we stop it so it doesn't interrupt the new play
			$Particles/DustParticles.emitting = true


