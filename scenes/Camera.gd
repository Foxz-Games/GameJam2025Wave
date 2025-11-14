extends Camera2D

@export_node_path("Node2D") var target_path: NodePath
@export var look_ahead_distance: float = 140.0
@export var look_ahead_vertical: float = 0.0
@export var velocity_threshold: float = 10.0
@export var flip_smooth: float = 6.0
@export var follow_smooth: float = 8.0

var _target: Node2D
var _last_target_pos: Vector2 = Vector2.ZERO
var _desired_dir: float = 0.0
var _smoothed_dir: float = 0.0

func _ready() -> void:
	if target_path != null and target_path != NodePath():
		_target = get_node_or_null(target_path)
	else:
		push_warning("Camera2D target_path not set! Please assign your player in the inspector.")
		return

	if _target:
		_last_target_pos = _target.global_position
	else:
		push_error("Camera2D: could not find node at target_path.")
		return

func _process(delta: float) -> void:
	if _target == null:
		return

	var now_pos: Vector2 = _target.global_position
	var vel: Vector2 = (now_pos - _last_target_pos) / max(delta, 0.000001)
	_last_target_pos = now_pos

	if abs(vel.x) > velocity_threshold:
		_desired_dir = sign(vel.x)
	else:
		_desired_dir = 0.0

	_smoothed_dir = move_toward(_smoothed_dir, _desired_dir, flip_smooth * delta)

	var look_offset: Vector2 = Vector2(_smoothed_dir * look_ahead_distance, look_ahead_vertical)
	var desired_cam_pos: Vector2 = now_pos + look_offset

	var t: float = 1.0 - pow(0.001, follow_smooth * delta)
	global_position = global_position.lerp(desired_cam_pos, t)
