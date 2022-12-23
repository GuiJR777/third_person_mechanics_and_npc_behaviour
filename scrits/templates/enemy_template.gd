class_name EnemyTemplate extends CharacterBody3D


@onready var face_direction: Marker3D = get_node("FaceDirection")
@onready var forget_about_it_timer: Timer = get_node("ForgetAboutIt")
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

@export var turn_speed: float = 3.0

var point_of_interest: Vector3
var target: Node3D


enum status {
	NEUTRAL,
	ALERT,
	DANGER
}

enum states {
	IDLE,
	SEARCHING,
	OBSERVING,
	PURSUIT
}

var current_state = states.IDLE
var current_status = status.NEUTRAL

var is_searching: bool = false


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

	if current_status == status.DANGER:
		current_state = states.PURSUIT


func _physics_process(delta: float) -> void:
	match current_state:
		states.IDLE:
			animation_player.play("idle")
			pass

		states.SEARCHING:
			animation_player.play("observing")

		states.OBSERVING:
			animation_player.play("idle")
			face_direction.look_at(point_of_interest, Vector3.UP)
			rotate_y(deg_to_rad(face_direction.rotation.y * turn_speed))

		states.PURSUIT:
			if not target:return
			animation_player.play("idle")
			var target_position: Vector3 = target.global_transform.origin
			face_direction.look_at(target_position, Vector3.UP)
			rotate_y(deg_to_rad(face_direction.rotation.y * turn_speed))



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
