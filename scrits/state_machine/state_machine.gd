class_name StateMachine extends Node

var current_state: State = null
var states: Dictionary = {}


func add_state(name: String, state: State) -> void:
	states[name] = state


func set_state(name: String) -> void:
	if name in states:
		if current_state:
			current_state.exit()

		current_state = states[name]
		current_state.enter()

	else:
		print("State not found:", name)


func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)
