class_name EnemyPatrolState extends EnemyState

static var state_name = "EnemyPatrolState"

func get_state_name() -> String:
	return state_name

func process(_delta: float) -> void:
	sprite.play('walk')
	
func physics_process(_delta: float) -> void:
	_apply_gravity(_delta)
		
	var facingL = sprite.flip_h
	if abs(enemy.velocity.x) == 0:
		enemy.velocity.x = -enemy.patrol_speed if facingL else enemy.patrol_speed
			
	if facingL and enemy.player_detection_left.is_colliding() or not facingL and enemy.player_detection_right.is_colliding():
		state_machine.transition(EnemyAttackState.state_name)
		return
		
	# stay on platform
	elif not enemy.floor_detector_left.is_colliding():
		enemy.velocity.x = enemy.patrol_speed
		sprite.flip_h = false
	elif not enemy.floor_detector_right.is_colliding():
		enemy.velocity.x = -enemy.patrol_speed
		sprite.flip_h = true
	
	#if is_on_wall():
		#velocity.x = -velocity.x
