class_name EnemyController extends CharacterBody2D

@export_group("Idle State")
@export var idle_min_time: float = 1.0
@export var idle_max_time: float = 2.0

@export_group("Patrol State")
@export var patrol_speed: float = 100.0

@export_group("Attack State")
@export var attack_dash_speed: float = 300

@export_group("Detection")
@export var player_detection_distance: float = 100.0

@onready var sprite = $AnimatedSprite2D
@onready var state_machine = $StateMachine

@onready var floor_detector_left = $FloorDetection_Left
@onready var floor_detector_right = $FloorDetection_Right
@onready var player_detection_left = $PlayerDetection_Left
@onready var player_detection_right = $PlayerDetection_Right


func _ready() -> void:
	_update_player_detection_distance()
	var states: Array[State] = [
		EnemyIdleState.new(self),
		EnemyPatrolState.new(self),
		EnemyAttackState.new(self),
	]
	state_machine.start_machine(states)

func _physics_process(delta: float) -> void:
	move_and_slide()

func _update_player_detection_distance() -> void:
	var distance: float = abs(player_detection_distance)
	player_detection_left.target_position.x = -distance
	player_detection_right.target_position.x = distance

#
#func _attackingTime(time):
	#attacking = true
	#await get_tree().create_timer(time).timeout
	#attacking = false
