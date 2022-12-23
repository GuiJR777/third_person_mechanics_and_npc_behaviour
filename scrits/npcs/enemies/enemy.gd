class_name Enemy extends EnemyTemplate


var animations_map: Dictionary = {
	states.IDLE: "Idle",
	states.SEARCHING: "Searching",
	states.OBSERVING: "Idle",
	states.PURSUIT: "Walk",
	states.ATTACK: "Attack(1h)",
}

func _physics_process(delta: float) -> void:
	match current_state:
		states.IDLE:
			stop_movement()

		states.SEARCHING:
			stop_movement()

		states.OBSERVING:
			face_direction.look_at(point_of_interest, Vector3.UP)
			rotate_y(deg_to_rad(face_direction.rotation.y * turn_speed))
			stop_movement()

		states.PURSUIT:
			if not target:return

			var target_position: Vector3 = target.global_transform.origin

			face_direction.look_at(target_position, Vector3.UP)
			rotate_y(deg_to_rad(face_direction.rotation.y * turn_speed))

			update_moving_target_location(target_position)
			move_to_target(delta)

		states.ATTACK:
			stop_movement()
			var target_position: Vector3 = target.global_transform.origin
			update_moving_target_location(target_position)
			var can_attack: bool = attack_check_ray.is_colliding()

			if can_attack:
				print("Atacando")

			if navigation.distance_to_target() > min_distance_to_attack:
				target_in_reach = false

	animation_player.play(animations_map.get(current_state))
	apply_gravity(delta)
	move_and_slide()
