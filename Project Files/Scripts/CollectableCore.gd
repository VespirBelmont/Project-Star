extends Node

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
	yield(get_tree().create_timer(1), "timeout")
	set_process(true)

func _process(delta):
	if target == null: return
	
	var drop_node_pos = get_node("DropNode").global_position
	
	var movement = (target.global_position - drop_node_pos).normalized()
	velocity = (movement * 50) * delta
	
	get_node("DropNode").global_position += velocity

func body_detected(body):
	if body.is_in_group("Player"):
		collected(body)

func area_detected(area):
	print("Area Hit")
	if area.is_in_group("Magnet"):
		print("Follow Player")
		follow_player(area.get_parent())
