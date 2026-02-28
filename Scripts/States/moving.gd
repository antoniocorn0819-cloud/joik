extends CharacterState

@export var detector: Area2D




func enter():
	#if !detector.get_overlapping_bodies():
		#on_child_transition(current_state, Constants.StateIdentifiers.Air)
	#else:
		#on_child_transition(current_state, Constants.StateIdentifiers.Water)
	pass



var cumulative_velocity_difference: Vector2 = Vector2(0,0)
var collision: KinematicCollision2D

func physics(delta):
	current_state.physics(delta)
	character.look_at(character.get_global_mouse_position())
	
	
	var old_velocity_magnitude: Vector2 = character.velocity
	
	# processes physics
	character.move_and_slide()
	
	var velocity_difference = old_velocity_magnitude - character.velocity
	
	character.swim_handler(Input.is_action_pressed("move"), current_state.identifier)
	
	# collision magnitude detection code only needed for vfx, sfx, and now wall bouncing
	# I would move it, but it is more convenient here
	
	# gets difference in velocity magnitudes before and after frame
	
	 # if the difference is large enough, it is added to the total
	if velocity_difference.length() > Constants.sfx.COLISION_VELOCITY_THRESHOLD:
		cumulative_velocity_difference += velocity_difference
		if character.get_slide_collision(0) != null:
			collision = character.get_slide_collision(0)
			
	# if it is not, the cumulative velocity difference is checked, passed to the hit handler, and reset
	elif cumulative_velocity_difference.length() > Constants.sfx.COLISION_VELOCITY_THRESHOLD:
		
		if collision:
			pass
			character.velocity = character.bounce_calculator(character.velocity, cumulative_velocity_difference, collision.get_normal(), Constants.movement.WALL_BOUNCE_ELASTICITY)
		character.hit_handler(cumulative_velocity_difference.length(), current_state.identifier)
		
		cumulative_velocity_difference = Vector2(0,0)



func body_entered(body):
	match body.local_type:
		Constants.CollisionTypes.Reset:
			Transition.emit(self, Constants.StateIdentifiers.Reset)
		Constants.CollisionTypes.Water:
			on_child_transition(current_state, Constants.StateIdentifiers.Water)
	current_state.body_entered(body)


func area_entered(area):
	match area.local_type:
		Constants.CollisionTypes.Bounce:
		# temporary solution
			var angle = (2 * area.rotation) - character.velocity.angle()
			character.velocity = Vector2.from_angle(angle) * character.velocity.length()
			
			character.boing_handler(character.velocity, character.position, current_state)


func body_exited(body):
	if !detector.get_overlapping_bodies():
		on_child_transition(current_state, Constants.StateIdentifiers.Air)


func input(event):
	# reuse in death code
	if event.is_action_pressed("reset_player"):
		Transition.emit(self, Constants.StateIdentifiers.Reset)
