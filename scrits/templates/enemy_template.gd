class_name EnemyTemplate extends CharacterBody3D


@onready var face_direction: Marker3D = get_node("FaceDirection")
@onready var forget_about_it_timer: Timer = get_node("ForgetAboutIt")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var navigation: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var attack_check_ray: RayCast3D = get_node("AttackRay")

@export var turn_speed: float = 3.0
@export var default_speed: float = 3.0
@export var min_distance_to_attack: float = 2.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed: float = default_speed
var point_of_interest: Vector3
var target: Node3D
var target_in_reach: bool = false


enum status {
	NEUTRAL,
	ALERT,
	DANGER
}

enum states {
	IDLE,
	SEARCHING,
	OBSERVING,
	PURSUIT,
	ATTACK
}

var current_state = states.IDLE
var current_status = status.NEUTRAL

var is_searching: bool = false


func _ready() -> void:
	navigation.target_desired_distance = min_distance_to_attack
	attack_check_ray.target_position = Vector3(0, 0, - min_distance_to_attack)


func _process(delta: float) -> void:
	var has_a_point_of_interest: bool = point_of_interest != Vector3.ZERO
	var has_a_target: bool = target != null

	if not has_a_point_of_interest and not has_a_target and not is_searching:
		current_status = status.NEUTRAL

	elif not has_a_point_of_interest and not has_a_target and is_searching:
		current_status = status.ALERT

	elif has_a_point_of_interest and not has_a_target:
		current_status = status.ALERT

	elif has_a_target:
		current_status = status.DANGER


	if current_status == status.NEUTRAL:
		current_state = states.IDLE

	if current_status == status.ALERT and is_searching:
		current_state = states.SEARCHING

	elif current_status == status.ALERT and not is_searching:
		current_state = states.OBSERVING

	if current_status == status.DANGER and not target_in_reach:
		current_state = states.PURSUIT

	elif current_status == status.DANGER and target_in_reach:
		current_state = states.ATTACK


func _physics_process(delta: float) -> void:
	match current_state:
		states.IDLE:
			animation_player.play("idle")
			stop_movement()

		states.SEARCHING:
			animation_player.play("observing")
			stop_movement()

		states.OBSERVING:
			animation_player.play("idle")
			face_direction.look_at(point_of_interest, Vector3.UP)
			rotate_y(deg_to_rad(face_direction.rotation.y * turn_speed))
			stop_movement()

		states.PURSUIT:
			if not target:return
			animation_player.play("idle")

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

	apply_gravity(delta)
	move_and_slide()


func apply_gravity(delta: float) -> void:
	velocity.y -= gravity * delta


func update_moving_target_location(target_location: Vector3) -> void:
	navigation.set_target_location(target_location)

func move_to_target(delta: float) -> void:
	var current_location: Vector3 = global_transform.origin
	var next_location: Vector3 = navigation.get_next_location()
	var new_velocity: Vector3 = (next_location - current_location).normalized()

	navigation.set_velocity(new_velocity)


func stop_movement() -> void:
	velocity.x = move_toward(velocity.x, 0, speed)
	velocity.z = move_toward(velocity.z, 0, speed)


func _on_vision_area_have_a_point_of_interest(finded_point_of_interest: Vector3) -> void:
	point_of_interest = finded_point_of_interest
	is_searching = false


func _on_vision_area_have_a_target(finded_target: Node3D) -> void:
	point_of_interest = Vector3.ZERO
	target = finded_target
	is_searching = false


func _on_forget_about_it_timeout() -> void:
	is_searching = false


func _on_pursuit_area_body_exited(body: Node3D) -> void:
	if target:
		target = null
		await get_tree().create_timer(2).timeout
		forget_about_it_timer.start()
		is_searching = true


func _on_vision_area_lost_sight_of() -> void:
	point_of_interest = Vector3.ZERO


func _on_navigation_agent_3d_target_reached() -> void:
	target_in_reach = true


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = velocity.move_toward(safe_velocity * speed, 0.25).x
	velocity.z = velocity.move_toward(safe_velocity * speed, 0.25).z
