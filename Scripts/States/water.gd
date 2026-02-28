extends CharacterState



func physics(delta):
	if Input.is_action_pressed("move"):
		character.velocity += Constants.movement.ACCELERATION * delta * ((character.get_global_mouse_position() - character.global_position).normalized())
