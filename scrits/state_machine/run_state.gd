class_name RunState extends State


func enter():
	PlayerGlobals.current_state = self.name
	owner.jump_count = 0
	owner.animation_playback.travel(self.name)
	owner.speed = owner.default_speed * 2


func update(delta):
	owner.apply_gravity(delta)
	var direction = owner.align_direction_with_camera(owner.direction)
	owner.apply_movement(direction, delta)
	owner.look_to_direction_of_movement(direction)


func exit():
	owner.speed = owner.default_speed
