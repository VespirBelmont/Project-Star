extends Node2D

export (Vector2) var offset = Vector2()

export (float) var scroll_speed = 5

func _ready():
	setup_limits()
	
	set_process(false)


func run_cam():
	set_process(true)

func stop_cam():
	set_process(false)

func setup_limits():
	#$Cam.limit_top = $Limits/TopLimit.global_position.y
	$Cam.limit_bottom = $Limits/BottomLimit.global_position.y
	$Cam.limit_right = $Limits/RightLimit.global_position.x
	$Cam.limit_left = $Limits/LeftLimit.global_position.x


func _process(delta):
	position.y -= scroll_speed * delta


