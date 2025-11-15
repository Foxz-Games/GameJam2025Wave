class_name EnemyState extends State

var enemy: EnemyController
var sprite: AnimatedSprite2D
var state_machine: StateMachine

func _init(enemy_controller: EnemyController) -> void:
	enemy = enemy_controller
	sprite = enemy.sprite
	state_machine = enemy.state_machine
