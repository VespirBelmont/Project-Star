extends Node2D

export (PackedScene) var projectile_tscn

export (bool) var active_weapon = false
var can_fire = true

export (int) var health_modifier = 0
export (int) var speed_modifier = 0
export (int) var damage_modifier = 0
export (Vector2) var shoot_direction = Vector2(0, -1)
export (float) var shoot_speed

export (String, "Player", "Enemy") var target = "Enemy"

export (bool) var reload_feedback_active = true


func shoot():
	if not can_fire: return
	
	var projectile = projectile_tscn.instance()
	$Bullets.add_child(projectile)
	projectile.setup(damage_modifier, shoot_direction, shoot_speed, target)
	projectile.global_position = $ProjectileSpawnPos.global_position
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


