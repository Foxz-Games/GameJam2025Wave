class_name PlayerState extends State

var player: PlatformerController2D
var anim: AnimatedSprite2D
var collider: CollisionShape2D
var state_machine: StateMachine

func _init(player_controller: PlatformerController2D) -> void:
	player = player_controller
	anim = player.anim
	collider = player.col
	state_machine = player.state_machine

func _apply_gravity(delta: float) -> void:
	if not player.is_on_floor():
		player.velocity.y += player.appliedGravity * delta
