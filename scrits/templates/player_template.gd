class_name PlayerTemplate extends CharacterBody3D

# Player controlers
@onready @export var pivot: Marker3D
@onready @export var spring_arm: SpringArm3D
@onready @export var floor_checker: RayCast3D
@onready @export var animation_tree: AnimationTree
@onready @export var state_machine: StateMachine

# Physics variables
@export var default_speed: float = 5.0
@export var acceleration: float = 70
@export var jump_impulse: float = 3.5
@export var max_jumps: int = 2

@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]


var speed: float = default_speed
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump_count: int = 0
var direction: Vector3 = Vector3.ZERO

var is_hiden: bool = false
var is_on_ground: bool = false


# Player moviments
func apply_jump_impulse() -> void:
	velocity.y = jump_impulse
	jump_count += 1


func apply_gravity(delta: float) -> void:
	velocity.y -= gravity * delta


func is_in_air() -> bool:
	return not is_on_floor() and not floor_checker.is_colliding()


func get_direction_for_horizontal_movement(input_direction: Vector2) -> Vector3:
	return transform.basis * Vector3(input_direction.x, 0, input_direction.y)


func get_direction_for_vertical_movement(input_direction: Vector2) -> Vector3:
	return transform.basis * Vector3(input_direction.x, input_direction.y, 0)


func align_direction_with_camera(direction: Vector3) -> Vector3:
	return direction.rotated(Vector3.UP, spring_arm.rotation.y).normalized()


func apply_movement(direction: Vector3, delta: float) -> void:
	velocity.x = velocity.move_toward(direction * speed, acceleration * delta).x
	velocity.z = velocity.move_toward(direction * speed, acceleration * delta).z


func stop_movement() -> void:
	velocity.x = move_toward(velocity.x, 0, speed)
	velocity.z = move_toward(velocity.z, 0, speed)


func look_to_direction_of_movement(direction: Vector3) -> void:
	pivot.look_at(position + direction, Vector3.UP)


func _process(delta: float) -> void:
	is_on_ground = !is_in_air()

