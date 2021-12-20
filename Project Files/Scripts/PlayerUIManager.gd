extends Control

var player_node

export var health_bar_colors = {
								"High": null,
								"Medium": null,
								"Low": null,
								"Critical": null
								}

export var health_bar_percents = {
								"High": null,
								"Medium": null,
								"Low": null,
								"Critical": null
								}

func _ready():
	PlayerInfo.connect("CurrencyUpdated", self, "update_currency")
	PlayerInfo.change_currency(0)

func setup(_player_node):
	player_node = _player_node
	update_health()
	
	$Portrait/PlayerIDLabel.text = "P%s" % player_node.player_id

func update_health():
	$Healthbar/Progress.max_value = player_node.get_node("Modules/HealthSystem").health_max
	$Healthbar/Progress.value = player_node.get_node("Modules/HealthSystem").health_current
	
	var health_percent = ($Healthbar/Progress.value * 100) / $Healthbar/Progress.max_value
	if health_percent >= health_bar_percents.Medium:
		$Healthbar/Progress.tint_progress = health_bar_colors.High
	elif health_percent >= health_bar_percents.Low:
		$Healthbar/Progress.tint_progress = health_bar_colors.Medium
	elif health_percent >= health_bar_percents.Critical:
		$Healthbar/Progress.tint_progress = health_bar_colors.Low
	else:
		$Healthbar/Progress.tint_progress = health_bar_colors.Critical


func player_hurt():
	$Portrait/PilotSprite/AnimationPlayer.play("Hurt")
	yield($Portrait/PilotSprite/AnimationPlayer, "animation_finished")
	
	if player_node.get_node("Modules/HealthSystem").health_current == 0:
		$Portrait/PilotSprite/AnimationPlayer.play("Dead")
		$Healthbar/Progress.value = 0
	else:
		$Portrait/PilotSprite/AnimationPlayer.play("Idle")

func update_currency(_amount):
	$Currency/AmountLabel.text = str(_amount)
