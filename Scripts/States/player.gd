extends CharacterState



func _physics_process(delta):
	physics(delta)


func _on_detector_body_entered(body):
	body_entered(body)

func _on_detector_body_exited(body):
	body_exited(body)


func _on_detector_area_entered(area):
	area_entered(area)

func _input(event):
	input(event)

func input(event):
	
	# zoom controls
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if character.camera.zoom.x < Constants.control.ZOOM_MAX:
				character.camera.zoom += Constants.control.ZOOM_INCREMENT
			else:
				character.camera.zoom = Vector2(Constants.control.ZOOM_MAX, Constants.control.ZOOM_MAX)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if character.camera.zoom.x > Constants.control.ZOOM_MIN:
				character.camera.zoom -= Constants.control.ZOOM_INCREMENT
			else:
				character.camera.zoom = Vector2(Constants.control.ZOOM_MIN,Constants.control.ZOOM_MIN)

	current_state.input(event)
