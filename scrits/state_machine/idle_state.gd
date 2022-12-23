class_name IdleState extends State


func update(delta):
	owner.apply_gravity(delta)
	owner.stop_movement()
