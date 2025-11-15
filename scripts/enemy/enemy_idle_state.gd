class_name EnemyIdleState extends EnemyState

static var state_name = "EnemyIdleState"

var timer: float = 0
 
func get_state_name() -> String:
	return state_name
	
func enter() -> void:
	timer = randf_range(enemy.idle_min_time, enemy.idle_max_time)

func process(_delta: float) -> void:
	sprite.play('idle')
	
func physics_process(_delta: float) -> void:
	enemy.velocity = Vector2(0, 0)
	
	if not enemy.is_on_floor_only():
		enemy.velocity += enemy.get_gravity() * _delta
	
	timer -= _delta
	if timer <= 0:
		state_machine.transition(EnemyPatrolState.state_name)
