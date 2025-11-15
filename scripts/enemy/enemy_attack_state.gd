class_name EnemyAttackState extends EnemyState

static var state_name = "EnemyAttackState"

const DASHING_SPEED = 125.0
var attacking = false
	
func get_state_name() -> String:
	return state_name

func enter() -> void:
	sprite.play('dash')

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	if not enemy.is_on_floor_only():
		enemy.velocity += enemy.get_gravity() * _delta
	
	if not sprite.is_playing():
		state_machine.transition(EnemyIdleState.state_name)
	
	enemy.velocity.x = -DASHING_SPEED if sprite.flip_h else DASHING_SPEED
		
	# stay on platform
	if not enemy.floor_detector_left.is_colliding():
		enemy.velocity.x = DASHING_SPEED
		sprite.flip_h = false
	elif not enemy.floor_detector_right.is_colliding():
		enemy.velocity.x = -DASHING_SPEED
		sprite.flip_h = true
