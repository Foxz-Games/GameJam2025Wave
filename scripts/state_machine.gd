class_name StateMachine extends Node

@export var is_log_enabled: bool = false

var current_state: State
var states: Dictionary = {}
var _parent_node_name: String

func start_machine(init_states: Array[State]) -> void:
	_parent_node_name = get_parent().name
	
	for state in init_states:
		states[state.get_state_name()] = state
		
	current_state = init_states[0]
	
	if is_log_enabled:
		print("[%s]: Entering state \"%s\"" % [_parent_node_name, current_state.get_state_name()])
		
	current_state.enter()
	
func _process(delta: float) -> void:
	current_state.process(delta)
	
func _physics_process(delta: float) -> void:
	current_state.physics_process(delta)
	
func transition(new_state_name: String) -> void:
	var new_state: State = states.get(new_state_name)
	var current_state_name = current_state.get_state_name()
	
	if new_state == null:
		push_error("Could not transition to a non-existent state (%s)." % new_state_name)
		return
	if current_state_name == new_state_name:
		push_error("Could not transition to the current state. Ignoring request.")
		return
		
	if is_log_enabled:
		print("[%s]: Exiting state \"%s\"" % [_parent_node_name, current_state.get_state_name()])
	current_state.exit()
		
	current_state = new_state
	
	if is_log_enabled:
		print("[%s]: Entering state \"%s\"" % [_parent_node_name, current_state.get_state_name()])
	current_state.enter()
	
