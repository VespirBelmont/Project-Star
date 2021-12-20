extends Area2D

var damage = 1
var targets

var move_speed = 1
var move_direction = Vector2(0, 0)

export (float) var movement_delay = 1.5
export (float) var delay_speed_mod = 0.3
export (bool) var destruction_anim = false

func setup(_damage, _move_direction, _speed, _targets):
	damage = _damage
	move_direction = _move_direction
	move_speed = _speed
	targets = _targets
	
	if movement_delay != 0:
		move_speed *= delay_speed_mod
		yield(get_tree().create_timer(movement_delay), "timeout")
		move_speed = _speed


func _process(delta):
	position += (move_direction * move_speed)


func body_hit(body):
	for tag in targets:
		if body.is_in_group(tag):
			body.get_node("Modules/HealthSystem").take_damage(damage, 0, self.global_position)
			destroy()
			break


func destroy():
	set_process(false)
	$AreaCollider.set_deferred("disabled", true)
	$Sprite.hide()
	
	if destruction_anim:
		$ImpactFX/Anim.play("Impact")
		yield($ImpactFX/Anim, "animation_finished")
	self.queue_free()
