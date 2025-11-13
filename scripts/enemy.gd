extends CharacterBody2D

enum State {
	IDLE,
	PATROL,
	WALKING,
	ATTACK,
	DEAD,
}

const SPEED = 75.0
const JUMP_VELOCITY = -400.0

@export var _state = State.PATROL
@onready var sprite = $AnimatedSprite2D
@onready var floor_detector_left = $FloorDetection_Left
@onready var floor_detector_right = $FloorDetection_Right
@onready var player_detection = $PlayerDetection

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	match _state:
		State.PATROL:
			if player_detection.is_colliding():
				_state = State.ATTACK
			elif not floor_detector_left.is_colliding():
				velocity.x = SPEED
				sprite.flip_h = false
			elif not floor_detector_right.is_colliding():
				velocity.x = -SPEED
				sprite.flip_h = true
			
			if is_on_wall():
				velocity.x = -velocity.x
				
			sprite.play("walk")
		
		State.ATTACK:
			sprite.play("dash")

	move_and_slide()
