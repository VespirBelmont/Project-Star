extends Area2D

export (int) var damage = 1
export (Array, String, "Player", "Enemy", "Hazard") var targets

export (float) var move_speed = 1
var move_direction : Vector2

func setup(_damage, _move_direction, _speed, _targets):
	damage = _damage
	move_direction = _move_direction
	move_speed = _speed
	targets = _targets

func _process(delta):
	position += (move_direction * move_speed)


func body_hit(body):
	print(targets)
	for tag in targets:
		if body.is_in_group(tag):
			body.get_node("Modules/HealthSystem").take_damage(damage, 0, self.global_position)
			destroy()
			break


func destroy():
	self.queue_free()
