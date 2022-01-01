extends Area2D

var damage = 1 #This is the damage the projectile does
var targets #These are the target tags that'll tell the projectile what it can hit

var move_speed = 1 #This is movement speed
var move_direction = Vector2(0, 0) #This is the direction the projectile moves

export (float) var movement_delay = 1.5 #This is the length of the movement delay
export (float) var delay_speed_mod = 0.3 #This is a delay that makes the projectile move slower at first.

export (bool) var destruction_anim = false #This will tell the projectile if there's a destruction animation


#This handles setting up the projectile
func setup(_damage, _move_direction, _speed, _targets):
	#Sets up the basic stats
	damage = _damage
	move_direction = _move_direction
	move_speed = _speed
	targets = _targets
	
	if move_direction.x > 0:
		self.rotation_degrees = 90
	elif move_direction.x < 0:
		self.rotation_degrees = 90
	
	#If there's movement delay
	if movement_delay != 0:
		move_speed *= delay_speed_mod #Set the move slow speed
		yield(get_tree().create_timer(movement_delay), "timeout") #Wait for the delay
		move_speed = _speed #Then set the normal move speed


#This runs every tick
func _process(delta):
	#This moves the projectile.
	position += (move_direction * move_speed) * delta


#This handles a body getting hit by the projectile
func body_hit(body):
	if body == null: #If the body is not there (null)
		print("ProjectileTemplate.gd | CRASH | Body was Null") #Leave this nift comment
		return #Then leave the function
	
	#Otherwise run through all available target tags
	for tag in targets:
		if body.is_in_group(tag): #If the body matches one of the tags
			#Give damage to the target's health system
			body.get_node("Modules/HealthSystem").take_damage(damage, 0, self.global_position)
			destroy() #Then destroy the projectile
			break #And break the loop

#This handles removing the projectile from the game
func destroy(off_screen = false):
	set_process(false) #This turns off the process function
	$AreaCollider.set_deferred("disabled", true) #The projectile collider gets disabled
	$Sprite.hide() #Then hide the sprite
	
	#If there's a destruction animation
	if destruction_anim and not off_screen:
		$ImpactFX/Anim.play("Impact") #It'll play the animation
		yield($ImpactFX/Anim, "animation_finished") #Wait for it to end
	
	self.queue_free() #Then get rid of it


