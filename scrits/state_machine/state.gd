class_name State extends Node


func enter():
	PlayerGlobals.current_state = self.name
	owner.jump_count = 0
	owner.animation_playback.travel(self.name)

func update(delta):
	pass

func exit():
	pass
