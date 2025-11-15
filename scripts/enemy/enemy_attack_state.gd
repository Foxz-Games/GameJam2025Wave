class_name EnemyAttackState extends EnemyState

static var state_name = "EnemyAttackState"

const DASH_SPEED = 125.0
	
func get_state_name() -> String:
	return state_name

func enter() -> void:
	sprite.play('dash')

func physics_process(_delta: float) -> void:
	_apply_gravity(_delta)
	
	if not sprite.is_playing():
		state_machine.transition(EnemyIdleState.state_name)
		return
	
	enemy.velocity.x = -DASH_SPEED if sprite.flip_h else DASH_SPEED
		
	# stay on platform
	if not enemy.floor_detector_left.is_colliding():
		enemy.velocity.x = DASH_SPEED
		sprite.flip_h = false
	elif not enemy.floor_detector_right.is_colliding():
		enemy.velocity.x = -DASH_SPEED
		sprite.flip_h = true
