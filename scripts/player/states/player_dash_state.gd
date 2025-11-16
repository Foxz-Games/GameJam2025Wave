extends PlayerState
class_name PlayerDashState

static var state_name = "PlayerDashState"

func get_state_name() -> String:
	return state_name

func enter() -> void:
	if player.dashing:
		anim.speed_scale = 1
		anim.play("dash")

func physics_process(_delta: float) -> void:
	player._read_inputs()
	_handle_dash_cancel()
	
	if not player.dashing:
		if player.is_on_floor():
			state_machine.transition(PlayerIdleState.state_name)
		else:
			state_machine.transition(PlayerAirState.state_name)

func _handle_dash_cancel() -> void:
	if not player.dashCancel:
		return
	if player.dashing and player.velocity.x > 0 and player.leftTap:
		player.velocity.x = 0
	if player.dashing and player.velocity.x < 0 and player.rightTap:
		player.velocity.x = 0
