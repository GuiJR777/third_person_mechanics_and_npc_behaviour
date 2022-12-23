class_name FallState extends State


func enter():
	PlayerGlobals.current_state = self.name


func update(delta):
	owner.apply_gravity(delta)
