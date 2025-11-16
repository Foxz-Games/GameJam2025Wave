extends PlayerState
class_name PlayerWallState

static var state_name = "PlayerWallState"

func get_state_name() -> String:
	return state_name

func exit() -> void:
	player.is_wall_sliding = false
	player.latched = false

func process(delta: float) -> void:
	player.wall_jump_face_lock_timer = max(0.0, player.wall_jump_face_lock_timer - delta)
	if player.wall_jump_face_lock_timer <= 0.0:
		if player.rightHold:
			anim.scale.x = player.animScaleLock.x
		elif player.leftHold:
			anim.scale.x = player.animScaleLock.x * -1
	if player.latched and not player.wasLatched:
		anim.speed_scale = 1
		anim.play("latch")
	elif player.is_wall_sliding and anim.animation != "slide":
		anim.speed_scale = 1
		anim.play("slide")

func physics_process(delta: float) -> void:
	player._read_inputs()
	
	if player.try_start_dash():
		state_machine.transition(PlayerDashState.state_name)
		return
	
	if player.jumpTap:
		player._wallJump()
		state_machine.transition(PlayerAirState.state_name)
		return
	
	if player.is_on_floor():
		state_machine.transition(PlayerIdleState.state_name)
		return
	if not player.is_on_wall():
		state_machine.transition(PlayerAirState.state_name)
		return
	
	_apply_wall_constraints()

func _apply_wall_constraints() -> void:
	var manual_latch = player._is_manual_wall_latch_active()
	var auto_slide = player._should_auto_wall_slide()
	player.latched = manual_latch
	player.is_wall_sliding = false
	if manual_latch:
		player.appliedGravity = 0
		if player.velocity.y < 0:
			player.velocity.y += 50
		if player.velocity.y > 0:
			player.velocity.y = 0
		if player.movementInputMonitoring == Vector2(true, true):
			player.velocity.x = 0
	elif auto_slide:
		if player.velocity.y > player.wallSlideSpeed:
			player.velocity.y = player.wallSlideSpeed
		if player.movementInputMonitoring == Vector2(true, true):
			player.velocity.x = 0
		player.is_wall_sliding = true
	else:
		state_machine.transition(PlayerAirState.state_name)
		return
