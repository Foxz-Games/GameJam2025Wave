extends PlayerState
class_name PlayerIdleState

static var state_name = "PlayerIdleState"

func get_state_name() -> String:
	return state_name

func process(delta: float) -> void:
	_update_facing(delta)
	_play_ground_animations()

func physics_process(delta: float) -> void:
	if not player.dset:
		player.gdelta = delta
		player.dset = true
	player._read_inputs()
	
	_handle_horizontal_input(delta)
	_handle_crouch_and_roll(delta)
	
	if player.jumpTap and player.is_on_floor():
		player._jump()
		state_machine.transition(PlayerAirState.state_name)
		return
	
	if player.try_start_dash():
		state_machine.transition(PlayerDashState.state_name)
		return
	
	if player.is_on_floor() and player.groundPounding:
		player._endGroundPound()
	
	player.reset_ground_counters()
	
	if not player.is_on_floor():
		state_machine.transition(PlayerAirState.state_name)

func _update_facing(delta: float) -> void:
	player.wall_jump_face_lock_timer = max(0.0, player.wall_jump_face_lock_timer - delta)
	if player.wall_jump_face_lock_timer > 0.0:
		return
	if player.rightHold:
		anim.scale.x = player.animScaleLock.x
	elif player.leftHold:
		anim.scale.x = player.animScaleLock.x * -1

func _play_ground_animations() -> void:
	if player.crouching and not player.rolling:
		if abs(player.velocity.x) > 10:
			anim.speed_scale = 1
			anim.play("crouch_walk")
		else:
			anim.speed_scale = 1
			anim.play("crouch_idle")
		return
	
	if player.run and player.idle and not player.dashing and not player.walk:
		if abs(player.velocity.x) > 0.1 and player.is_on_floor():
			anim.speed_scale = abs(player.velocity.x / 150)
			anim.play("run")
		elif player.is_on_floor():
			anim.speed_scale = 1
			anim.play("idle")
	elif player.run and player.idle and player.walk:
		if abs(player.velocity.x) > 0.1 and player.is_on_floor():
			anim.speed_scale = abs(player.velocity.x / 150)
			if abs(player.velocity.x) < player.maxSpeedLock:
				anim.play("walk")
			else:
				anim.play("run")
		elif player.is_on_floor():
			anim.speed_scale = 1
			anim.play("idle")

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
	else:
		if not player.instantStop:
			player._decelerate(delta, false)
		else:
			player.velocity.x = 0
	
	if player.velocity.x > 0:
		player.wasMovingR = true
	elif player.velocity.x < 0:
		player.wasMovingR = false
		
	if player.rightTap:
		player.wasPressingR = true
	if player.leftTap:
		player.wasPressingR = false
	
	if player.runningModifier and not player.runHold:
		player.maxSpeed = player.maxSpeedLock / 2
	elif player.is_on_floor(): 
		player.maxSpeed = player.maxSpeedLock

func _handle_crouch_and_roll(delta: float) -> void:
	if player.crouch:
		if player.downHold and player.is_on_floor():
			player.crouching = true
		elif not player.downHold and not player.rolling:
			player.crouching = false
			
	if not player.is_on_floor():
		player.crouching = false
			
	if player.crouching:
		player.maxSpeed = player.maxSpeedLock / 2
		player.col.scale.y = player.colliderScaleLockY / 2
		player.col.position.y = player.colliderPosLockY + (8 * player.colliderScaleLockY)
	elif not player.runningModifier or (player.runningModifier and player.runHold):
		player.maxSpeed = player.maxSpeedLock
		player.col.scale.y = player.colliderScaleLockY
		player.col.position.y = player.colliderPosLockY
		
	if player.canRoll and player.is_on_floor() and player.rollTap and player.crouching:
		player._rollingTime(player.rollLength * 0.25)
		if player.wasPressingR and not (player.upHold):
			player.velocity.y = 0
			player.velocity.x = player.maxSpeedLock * player.rollLength
			player.dashCount += -1
			player.movementInputMonitoring = Vector2(false, false)
			player._inputPauseReset(player.rollLength * 0.0625)
		elif not (player.upHold):
			player.velocity.y = 0
			player.velocity.x = -player.maxSpeedLock * player.rollLength
			player.dashCount += -1
			player.movementInputMonitoring = Vector2(false, false)
			player._inputPauseReset(player.rollLength * 0.0625)
