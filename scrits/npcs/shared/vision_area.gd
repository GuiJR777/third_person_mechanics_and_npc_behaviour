extends Area3D


signal have_a_point_of_interest(point_of_interest: Vector3)
signal have_a_target(target: Node3D)
signal lost_sight_of

@onready var periferical_vision_ray: RayCast3D = get_node("PerifericalVisionRay")
@onready var focus: RayCast3D = get_node("Focus")
@onready var focus_animation: AnimationPlayer = get_node("Focus/AnimationPlayer")
@onready var npc: EnemyTemplate = owner

var bodie_in_periferical_vision: bool = false
var has_a_point_of_interest: bool = false
var has_a_target: bool = false

var point_of_interest: Vector3


func _physics_process(delta: float) -> void:
	__try_focus_on_body()
	__search_player()
	has_a_target = npc.target != null
	has_a_point_of_interest = npc.point_of_interest != Vector3.ZERO

	if not has_a_point_of_interest:
		focus_animation.play("idle")
	else:
		focus_animation.play("tracking")


func __try_focus_on_body() -> void:
	if not bodie_in_periferical_vision or has_a_target: return

	var overlaps_bodies = get_overlapping_bodies()

	if overlaps_bodies.size() > 0:
		for overlap_body in overlaps_bodies:
			if overlap_body.is_in_group("player"):
				var player: PlayerTemplate = overlap_body
				var player_position: Vector3 = player.global_transform.origin
				point_of_interest = Vector3(player_position.x, 1.2, player_position.z)

				periferical_vision_ray.look_at(point_of_interest)
				periferical_vision_ray.force_raycast_update()
				var can_see: bool = (
					periferical_vision_ray.is_colliding() and
					periferical_vision_ray.get_collider().is_in_group("player") and
					not player.is_hiden)

				if can_see:
					await get_tree().create_timer(1).timeout
					have_a_point_of_interest.emit(point_of_interest)


func __search_player() -> void:
	if focus.is_colliding():
		var collider := focus.get_collider()
		if collider.is_in_group("player"):
			bodie_in_periferical_vision = false
			have_a_target.emit(collider)



func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		bodie_in_periferical_vision = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		bodie_in_periferical_vision = false
		point_of_interest = Vector3.ZERO
		lost_sight_of.emit()
