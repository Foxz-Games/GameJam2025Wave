class_name EnemyPatrolState extends EnemyState

static var state_name = "EnemyPatrolState"

const WALKING_SPEED = 75.0
const ATTACK_LENGTH = 12.0

func get_state_name() -> String:
	return state_name

func process(_delta: float) -> void:
	sprite.play('walk')
	
func physics_process(_delta: float) -> void:
	_apply_gravity(_delta)
		
	var facingL = sprite.flip_h
	if abs(enemy.velocity.x) == 0:
		enemy.velocity.x = -WALKING_SPEED if facingL else WALKING_SPEED
			
	if facingL and enemy.player_detection_left.is_colliding() or not facingL and enemy.player_detection_right.is_colliding():
		state_machine.transition(EnemyAttackState.state_name)
		return
		
	# stay on platform
	elif not enemy.floor_detector_left.is_colliding():
		enemy.velocity.x = WALKING_SPEED
		sprite.flip_h = false
	elif not enemy.floor_detector_right.is_colliding():
		enemy.velocity.x = -WALKING_SPEED
		sprite.flip_h = true
	
	#if is_on_wall():
		#velocity.x = -velocity.x
