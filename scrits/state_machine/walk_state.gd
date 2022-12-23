class_name WalkState extends State


func update(delta):
	owner.apply_gravity(delta)
	var direction = owner.align_direction_with_camera(owner.direction)
	owner.apply_movement(direction, delta)
	owner.look_to_direction_of_movement(direction)
