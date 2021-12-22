extends Area2D

signal Collected

export var value = 0

var velocity = Vector2()
var target

func _ready():
	set_process(false)

func collected(body):
	emit_signal("Collected", body)

func follow_player(_follow_node):
	target = _follow_node
	
	set_process(true)

func _process(delta):
	if target == null: return
	
	var movement = (target.global_position - self.global_position).normalized()
	velocity = movement * 3
	
	self.global_position += velocity

func body_detected(body):
	if body.is_in_group("Player"):
		collected(body)

func area_detected(area):
	if area.is_in_group("Magnet"):
		follow_player(area.get_parent())
