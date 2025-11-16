extends PlayerState
class_name PlayerAirState

static var state_name = "PlayerAirState"

func get_state_name() -> String:
	return state_name

func process(delta: float) -> void:
	player.wall_jump_face_lock_timer = max(0.0, player.wall_jump_face_lock_timer - delta)
	var manual_latch_active = player._is_manual_wall_latch_active()
	if manual_latch_active:
		player.latched = true
	else:
		if player.latched:
			player.wasLatched = true
			player._setLatch(0.2, false)
		player.latched = false

	if player.wall_jump_face_lock_timer <= 0.0 and player.rightHold and not player.latched:
		anim.scale.x = player.animScaleLock.x
	if player.wall_jump_face_lock_timer <= 0.0 and player.leftHold and not player.latched:
		anim.scale.x = player.animScaleLock.x * -1
	
	if player.velocity.y < 0 and player.jump and not player.dashing:
		anim.speed_scale = 1
		anim.play("jump")
		
	if player.velocity.y > 40 and player.falling and not player.dashing and not player.crouching:
		anim.speed_scale = 1
		anim.play("falling")
		
	if player.latch and player.slide:
		if player.latched and not player.wasLatched:
			anim.speed_scale = 1
			anim.play("latch")
		if player.is_wall_sliding and player.velocity.y > 0 and player.slide and anim.animation != "slide":
			anim.speed_scale = 1
			anim.play("slide")
			
	if player.dashing:
		anim.speed_scale = 1
		anim.play("dash")

func physics_process(delta: float) -> void:
	player._read_inputs()
	_handle_horizontal_input(delta)
	_apply_air_physics(delta)
	_handle_air_jumps()
	_handle_dash_input(delta)
	_handle_corner_cutting()
	_handle_ground_pound()
	
	if player.is_on_floor():
		if player.groundPounding:
			player._endGroundPound()
		state_machine.transition(PlayerIdleState.state_name)
		return
	
	if player._is_manual_wall_latch_active() or player._should_auto_wall_slide():
		state_machine.transition(PlayerWallState.state_name)

func _handle_horizontal_input(delta: float) -> void:
	if player.rightHold and player.leftHold and player.movementInputMonitoring:
		if not player.instantStop:
			player._decelerate(delta, false)
		else:
			player.velocity.x = -0.1
	elif player.rightHold and player.movementInputMonitoring.x:
		if player.velocity.x > player.maxSpeed or player.instantAccel:
			player.velocity.x = player.maxSpeed
		else:
			player.velocity.x += player.acceleration * delta
		if player.velocity.x < 0:
			if not player.instantStop:
				player._decelerate(delta, false)
			else:
				player.velocity.x = -0.1
	elif player.leftHold and player.movementInputMonitoring.y:
		if player.velocity.x < -player.maxSpeed or player.instantAccel:
			player.velocity.x = -player.maxSpeed
		else:
			player.velocity.x -= player.acceleration * delta
		if player.velocity.x > 0:
			if not player.instantStop:
				player._decelerate(delta, false)
			else:
				player.velocity.x = 0.1
				
	if player.velocity.x > 0:
		player.wasMovingR = true
	elif player.velocity.x < 0:
		player.wasMovingR = false
		
	if player.rightTap:
		player.wasPressingR = true
	if player.leftTap:
		player.wasPressingR = false

func _apply_air_physics(delta: float) -> void:
	if player.velocity.y > 0:
		player.appliedGravity = player.gravityScale * player.descendingGravityFactor
	else:
		player.appliedGravity = player.gravityScale
	
	var manual_latch_active = player._is_manual_wall_latch_active()
	var auto_slide_active = player._should_auto_wall_slide()
	player.is_wall_sliding = false
	if player.is_on_wall() and not player.groundPounding:
		player.appliedTerminalVelocity = player.terminalVelocity
		if manual_latch_active:
			player.appliedGravity = 0
			
			if player.velocity.y < 0:
				player.velocity.y += 50
			if player.velocity.y > 0:
				player.velocity.y = 0
				
			if player.movementInputMonitoring == Vector2(true, true):
				player.velocity.x = 0
			
		elif auto_slide_active:
			if player.velocity.y > player.wallSlideSpeed:
				player.velocity.y = player.wallSlideSpeed
			if player.movementInputMonitoring == Vector2(true, true):
				player.velocity.x = 0
			player.is_wall_sliding = true
	elif not player.is_on_wall() and not player.groundPounding:
		player.appliedTerminalVelocity = player.terminalVelocity
	
	if player.gravityActive:
		if player.velocity.y < player.appliedTerminalVelocity:
			player.velocity.y += player.appliedGravity
		elif player.velocity.y > player.appliedTerminalVelocity:
				player.velocity.y = player.appliedTerminalVelocity
		
	if player.shortHopAkaVariableJumpHeight and player.jumpRelease and player.velocity.y < 0:
		player.velocity.y = player.velocity.y / player.jumpVariable

func _handle_air_jumps() -> void:
	if player.jumps == 1:
		if not player.is_on_floor() and not player.is_on_wall():
			if player.coyoteTime > 0 and not player.coyoteActive:
				player.coyoteActive = true
				player._coyoteTime()
				
		if player.jumpTap and not player.is_on_wall():
			if player.coyoteActive:
				player.coyoteActive = false
				player._jump()
			elif player.jumpBuffering > 0:
				player.jumpWasPressed = true
				player._bufferJump()
		elif player.jumpTap and player.is_on_wall() and not player.is_on_floor():
			if player.wallJump:
				player._wallJump()
	elif player.jumps > 1:
		if player.jumpTap and player.is_on_wall() and player.wallJump:
			player._wallJump()
		elif player.jumpTap and player.jumpCount > 0:
			player.velocity.y = -player.jumpMagnitude
			player.jumpCount = player.jumpCount - 1
			player._endGroundPound()

func _handle_dash_input(delta: float) -> void:
	if player.try_start_dash():
		state_machine.transition(PlayerDashState.state_name)
		return
	
	if player.dashing and player.velocity.x > 0 and player.leftTap and player.dashCancel:
		player.velocity.x = 0
	if player.dashing and player.velocity.x < 0 and player.rightTap and player.dashCancel:
		player.velocity.x = 0

func _handle_corner_cutting() -> void:
	if not player.cornerCutting:
		return
	if player.velocity.y < 0 and player.leftRaycast.is_colliding() and not player.rightRaycast.is_colliding() and not player.middleRaycast.is_colliding():
		player.position.x += player.correctionAmount
	if player.velocity.y < 0 and not player.leftRaycast.is_colliding() and player.rightRaycast.is_colliding() and not player.middleRaycast.is_colliding():
		player.position.x -= player.correctionAmount

func _handle_ground_pound() -> void:
	if player.groundPound and player.downTap and not player.is_on_floor() and not player.is_on_wall():
		player.request_ground_pound()
	if player.upToCancel and player.upHold and player.groundPounding:
		player._endGroundPound()
