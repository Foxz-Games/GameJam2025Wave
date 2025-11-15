class_name EnemyState extends State

var enemy: EnemyController
var sprite: AnimatedSprite2D
var state_machine: StateMachine

func _init(enemy_controller: EnemyController) -> void:
	enemy = enemy_controller
	sprite = enemy.sprite
	state_machine = enemy.state_machine

func _apply_gravity(_delta: float) -> void:
	if not enemy.is_on_floor_only():
		enemy.velocity += enemy.get_gravity() * _delta
