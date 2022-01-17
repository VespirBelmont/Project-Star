extends Node

onready var rotation_tween 
var target
export (float) var rotation_offset = 14.3
export (float) var rotation_speed = 0.8

onready var controller = get_parent().get_parent()

func _ready():
	rotation_tween = Tween.new()
	add_child(rotation_tween)

func set_target(new_target):
	target = new_target

func look():
	if target == null: return
	
	var start_transform = controller.rotation
	var direction = target.position - controller.position
	var final_rot = direction.angle() + rotation_offset
	
	rotation_tween.interpolate_property(controller, "rotation", 
										start_transform, final_rot, rotation_speed, 
										Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
										)
	rotation_tween.start()


