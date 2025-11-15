class_name EnemyController extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var state_machine = $StateMachine

@onready var floor_detector_left = $FloorDetection_Left
@onready var floor_detector_right = $FloorDetection_Right
@onready var player_detection_left = $PlayerDetection_Left
@onready var player_detection_right = $PlayerDetection_Right


func _ready() -> void:
	var states: Array[State] = [
		EnemyIdleState.new(self),
		EnemyPatrolState.new(self),
		EnemyAttackState.new(self),
	]
	state_machine.start_machine(states)

func _physics_process(delta: float) -> void:
	move_and_slide()

#
#func _attackingTime(time):
	#attacking = true
	#await get_tree().create_timer(time).timeout
	#attacking = false
