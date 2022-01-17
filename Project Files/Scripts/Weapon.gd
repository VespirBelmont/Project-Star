extends Node2D

onready var operator = get_parent().get_parent().get_parent()

export (Vector2) var base_movement = Vector2(0, -1)

export (PackedScene) var projectile_tscn

export (bool) var active_weapon = false
var can_fire = true

export (String, "Player", "Enemy") var party = "Player"

export (int) var health_modifier = 0
export (int) var speed_modifier = 0
export (int) var damage_modifier = 0
export (Vector2) var shoot_direction = Vector2(0, -1)
export (float) var shoot_speed

export (float) var knockback_power = 1
export (float) var knockback_duration = 1

export (Array, String, "Player", "Enemy", "Hazard") var target = ["Enemy"]

export (bool) var reload_feedback_active = true

export (String, "None", "SmallShake", "MediumShake", "LauncherShake") var cam_fx

onready var cooldown_timer_default = $CooldownTimer.wait_time

var active_mod = ""

func shoot():
	if not can_fire: 
		#$Audio/CantFire.play()
		return
	
	modifier_check()
	
	match active_mod:
		"Turbo Trigger":
			$CooldownTimer.wait_time = cooldown_timer_default * 0.5
	
	var projectile = projectile_tscn.instance()
	$Bullets.add_child(projectile)
	
	# * get_parent().get_parent().get_parent().scale
	projectile.setup(damage_modifier, operator.rotation, shoot_speed, target, knockback_power, knockback_duration)
	projectile.global_position = $ProjectileSpawnPos.global_position
	projectile.add_to_group(party)
	
	if cam_fx != "None":
		var cam_anim = get_parent().get_parent().get_parent().get_parent().get_parent().get_node("CamRig/Anim")
		cam_anim.play(cam_fx)
	
	$Audio/Shoot.play()
	$MuzzleFlashSprite/FlashAnim.play("Flash")
	
	can_fire = false
	$CooldownTimer.start()


func cooldown_finished():
	if reload_feedback_active:
		if get_parent().name == "Left":
			$ReloadedLabel/ReloadAnim.play("Reload_Left")
		else:
			$ReloadedLabel/ReloadAnim.play("Reload_Right")
	can_fire = true
	
	$CooldownTimer.wait_time = cooldown_timer_default



func modifier_check():
	active_mod = ""
	
	for mod in $Modules.get_children():
		if mod.equipped:
			active_mod = mod.name

