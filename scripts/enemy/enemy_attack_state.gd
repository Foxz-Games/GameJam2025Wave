class_name EnemyAttackState extends EnemyState

static var state_name = "EnemyAttackState"

const DASH_SPEED = 125.0
const WINDUP_LAST_FRAME = 3  # frames 0-3 are windup
const ROLL_LAST_FRAME = 8    # frames 4-8 are the rolling motion

var roll_direction := 1.0
	
func get_state_name() -> String:
	return state_name

func enter() -> void:
	if sprite.sprite_frames.get_animation_loop("dash"):
		sprite.sprite_frames.set_animation_loop("dash", false)
	sprite.frame = 0
	sprite.play('dash')
	roll_direction = -1.0 if sprite.flip_h else 1.0
	enemy.velocity.x = 0

func _apply_platform_constraints() -> void:
	if roll_direction < 0 and not enemy.floor_detector_left.is_colliding():
		roll_direction = 1.0
		sprite.flip_h = false
	elif roll_direction > 0 and not enemy.floor_detector_right.is_colliding():
		roll_direction = -1.0
		sprite.flip_h = true

func physics_process(_delta: float) -> void:
	_apply_gravity(_delta)
	
	if not sprite.is_playing():
		_handle_post_attack_transition()
		return

	var current_frame = sprite.frame
	if current_frame <= WINDUP_LAST_FRAME:
		enemy.velocity.x = 0
		return

	if current_frame <= ROLL_LAST_FRAME:
		_apply_platform_constraints()
		enemy.velocity.x = DASH_SPEED * roll_direction
	else:
		enemy.velocity.x = 0

func _handle_post_attack_transition() -> void:
	if _is_player_detected():
		state_machine.transition(EnemyAttackState.state_name)
	else:
		state_machine.transition(EnemyPatrolState.state_name)
