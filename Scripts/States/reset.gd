extends CharacterState


func enter():
	character.position = character.checkpoint_manager.death_manager(character.current_checkpoint_id)
	character.velocity = Vector2(0,0)
	Transition.emit(self, Constants.StateIdentifiers.Moving)
