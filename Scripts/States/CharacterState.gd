extends State
class_name CharacterState

## exports refernce to CharacterBody
@export var character: CharacterBody2D

func body_entered(body):
	if current_state:
		current_state.body_entered(body)

func body_exited(body):
	if current_state:
		current_state.body_exited(body)

func area_entered(area):
	if current_state:
		current_state.area_entered(area)

func input(event):
	if current_state:
		current_state.input(event)
