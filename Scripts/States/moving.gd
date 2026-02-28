extends CharacterState

@export var detector: Area2D

func enter():
	if !detector.get_overlapping_bodies():
		on_child_transition(current_state, Constants.StateIdentifiers.Air)
	else:
		on_child_transition(current_state, Constants.StateIdentifiers.Water)

func physics(delta):
	current_state.physics(delta)
	character.look_at(character.get_global_mouse_position())
	
	character.move_and_slide()

func body_entered(body):
	match body.local_type:
		Constants.CollisionTypes.Reset:
			Transition.emit(self, Constants.StateIdentifiers.Reset)
		Constants.CollisionTypes.Water:
			on_child_transition(current_state, Constants.StateIdentifiers.Water)
	current_state.body_entered(body)

func body_exited(body):
	if !detector.get_overlapping_bodies():
		on_child_transition(current_state, Constants.StateIdentifiers.Air)
