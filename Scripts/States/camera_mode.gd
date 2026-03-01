extends CharacterState

var input_vector: Vector2 = Vector2(0,0)

# change input code eventually

func physics(delta):
	if Input.is_action_pressed("move"):
		character.camera.global_position += input_vector * Constants.movement.CAMERA_SPEED_FAST * delta
	else:
		character.camera.global_position += input_vector * Constants.movement.CAMERA_SPEED_SLOW * delta
	
func input(event):
	input_vector = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if event.is_action_pressed("camera_swap"):
		Transition.emit(self, Constants.StateIdentifiers.Moving)
		print("camera_swap")

func exit():
	character.camera.global_position = character.position
