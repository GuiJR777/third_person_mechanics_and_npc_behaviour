extends SpringArm3D

@export var mouse_sensivity: float = 0.05

const MIN_X_ANGLE: float = -PI/4
const MAX_X_ANGLE: float = PI/8
const MIN_Y_ANGLE: float = 0.0
const MAX_Y_ANGLE: float = 360.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.x -= event.relative.y * mouse_sensivity
		rotation.x = clamp(rotation.x, MIN_X_ANGLE, MAX_X_ANGLE)

		rotation.y -= event.relative.x * mouse_sensivity

	if event.is_action_pressed("click"):
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
