class_name CapsulePlayer extends PlayerTemplate


func _ready() -> void:
	for state in state_machine.get_children():
		state_machine.add_state(state.name, state)
	state_machine.set_state("idle")


func _physics_process(delta: float) -> void:
	manage_states_with_player_inputs(delta)
	state_machine.update(delta)

	move_and_slide()


func manage_states_with_player_inputs(delta: float) -> void:
	var input_direction: Vector2 = Input.get_vector("weast", "east", "north", "south")
	direction = get_direction_for_horizontal_movement(input_direction)

	var is_moving: bool = direction != Vector3.ZERO

	var is_jumping: bool = Input.is_action_just_pressed("jump")
	var is_walking: bool = is_on_ground and is_moving and not is_jumping
	var is_idle: bool = not is_moving and is_on_ground and not is_jumping
	var is_falling: bool = not is_on_ground
	var is_running: bool = Input.is_action_pressed("run") and is_walking


	if is_jumping:
		state_machine.set_state("jump")

	elif is_falling:
		state_machine.set_state("fall")

	if is_running:
		state_machine.set_state("run")

	elif is_walking:
		state_machine.set_state("walk")

	if is_idle:
		state_machine.set_state("idle")


