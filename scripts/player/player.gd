extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

@export var speed = 300.0
@export var jump_velocity = -400.0


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left"):
		sprite.flip_h = true
	if Input.is_action_just_pressed("right"):
		sprite.flip_h = false
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	update_animation()
	move_and_slide()

func update_animation():
	if velocity.x != 0:
		sprite.play("run")
	else:
		sprite.play("idle")
