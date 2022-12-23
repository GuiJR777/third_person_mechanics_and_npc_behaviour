extends MeshInstance3D


@onready var right_eye: MeshInstance3D = get_node("Eyes")
@onready var left_eye: MeshInstance3D = get_node("Eyes2")

@onready var enemy: EnemyTemplate = owner

var eyes_color_map: Dictionary = {
	enemy.status.NEUTRAL: Color("198610"),
	enemy.status.ALERT: Color("c8dd10"),
	enemy.status.DANGER: Color("c81510")
}


func _process(delta: float) -> void:
	var color_to_eye: Color = eyes_color_map.get(enemy.current_status)
	change_material_color(right_eye, color_to_eye)
	change_material_color(left_eye, color_to_eye)


func change_material_color(body: MeshInstance3D, color: Color) -> void:
	var material = body.get_active_material(0)
	material.albedo_color = color
	body.set_surface_override_material(0, material)
