class_name StateMachine extends Node

signal state_entered(state_name: StringName, state: State)
signal state_exited(state_name: StringName, state: State)
signal state_transitioned(previous_state: StringName, new_state: StringName)

@export var is_log_enabled: bool = false

var current_state: State
var states: Dictionary = {}
var _parent_node_name: String
var _pending_transition: StringName = ""

func register_state(state: State) -> void:
	if state == null:
		return
	states[state.get_state_name()] = state

func start_machine(init_states: Array[State], initial_state_name: StringName = "") -> void:
	states.clear()
	_parent_node_name = get_parent().name
	for state in init_states:
		register_state(state)
	if initial_state_name == "" and init_states.size() > 0:
		initial_state_name = init_states[0].get_state_name()
	_start(initial_state_name)

func _start(initial_state_name: StringName) -> void:
	if states.is_empty():
		push_error("StateMachine cannot start without states.")
		return
	if initial_state_name == "":
		initial_state_name = states.keys()[0]
	_pending_transition = initial_state_name
	_apply_pending_transition()

func _process(delta: float) -> void:
	_apply_pending_transition()
	if current_state:
		current_state.process(delta)
	_apply_pending_transition()
	
func _physics_process(delta: float) -> void:
	_apply_pending_transition()
	if current_state:
		current_state.physics_process(delta)
	_apply_pending_transition()
	
func transition(new_state_name: StringName) -> void:
	if new_state_name == "":
		return
	_pending_transition = new_state_name
	if not current_state:
		_apply_pending_transition()

func get_state(state_name: StringName) -> State:
	return states.get(state_name)

func get_current_state_name() -> StringName:
	return current_state.get_state_name() if current_state else ""

func _apply_pending_transition() -> void:
	if _pending_transition == "":
		return
	var new_state: State = states.get(_pending_transition)
	if new_state == null:
		push_error("Could not transition to a non-existent state (%s)." % _pending_transition)
		_pending_transition = ""
		return
	var previous_state_name: StringName = ""
	var previous_state: State = current_state
	if current_state:
		previous_state_name = current_state.get_state_name()
		if is_log_enabled:
			print("[%s]: Exiting state \"%s\"" % [_parent_node_name, previous_state_name])
		current_state.exit()
		state_exited.emit(previous_state_name, previous_state)
	current_state = new_state
	_pending_transition = ""
	var reentering = previous_state_name == current_state.get_state_name()
	if is_log_enabled:
		var message = "Re-entering state" if reentering else "Entering state"
		print("[%s]: %s \"%s\"" % [_parent_node_name, message, current_state.get_state_name()])
	current_state.enter()
	state_entered.emit(current_state.get_state_name(), current_state)
	state_transitioned.emit(previous_state_name, current_state.get_state_name())
