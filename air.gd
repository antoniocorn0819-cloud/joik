extends CharacterState

func physics(delta):
	if not character.is_on_floor():
		character.velocity.y += Constants.movement.GRAVITY * delta

func body_entered(body):
	if body.local_type == Constants.CollisionTypes.Water:
		Transition.emit(self, Constants.StateIdentifiers.Water)
