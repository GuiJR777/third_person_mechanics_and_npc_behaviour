class_name JumpState extends State


func enter():
	PlayerGlobals.current_state = self.name
	owner.animation_playback.travel(self.name)


func update(delta):
	if owner.is_on_ground or owner.jump_count <= owner.max_jumps:
		owner.apply_jump_impulse()
		owner.jump_count += 1
