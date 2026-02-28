extends CharacterBody2D

@export var current_checkpoint_id: int = 1
@export var checkpoint_manager: Node
@export var camera: Camera2D
@export var animator: AnimationPlayer
@export var bubble_emitter: GPUParticles2D
@export var moving_machine: State

func bounce_calculator(current_velocity: Vector2,
 collision_velocity: Vector2, collision_normal: Vector2,
 collision_elasticity: float, minimum_bounce: float = 0.0) -> Vector2:
	# pretty simple
	var magnitude: float = abs(collision_velocity.dot(collision_normal)) * collision_elasticity
	if magnitude < minimum_bounce:
		return current_velocity
	
	return current_velocity + (collision_normal * magnitude)


# CODE PAST THIS POINT IS FOR SFX AND VFX

#---------------------------------------------------------------------------------------------------

func swim_handler(pressing: bool, state_type: Constants.StateIdentifiers) -> void:
	if pressing:
		animator.current_animation = "swim"
		bubble_emitter.emitting = false
		if state_type == Constants.StateIdentifiers.Water:
			bubble_emitter.emitting = true
	else:
		animator.current_animation = "idle"
		bubble_emitter.emitting = false




## handles splash related sfx and vfx
func splash_handler(fish_velocity: Vector2, fish_position: Vector2) -> void:
	# breaks if splash is too tiny
	var magnitude = fish_velocity.length()
	
	if magnitude < Constants.sfx.SPLASH_THRESHOLD:
		return
	
	# code for vfx
	
	# calculates modifier (1.0 being neutral) for explosion velocity
	var explosion_modifier: float = magnitude * Constants.vfx.BUBBLE_VELOCITY_CONVERTER
	
	# calculates offset for explosion position to account for hitbox radius
	var offset: Vector2 = fish_velocity.normalized() * Constants.vfx.DETECTOR_RADIUS
	
	# creates bubble explosion
	bubble_explosion_creator(fish_position + offset, fish_velocity.normalized(), explosion_modifier)
	
	# code for sfx
	
	
	if magnitude > Constants.sfx.SPLASH_LOUD_THRESHOLD:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Splash_Loud)
	elif magnitude > Constants.sfx.SPLASH_MEDIUM_THRESHOLD:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Splash_Medium)
	else:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Splash_Quiet)




## handles plop related vfx and sfx
func plop_handler(fish_velocity: Vector2, fish_position: Vector2) -> void:
	# breaks if plop is too tiny
	var magnitude = fish_velocity.length()
	
	if magnitude < Constants.sfx.PLOP_THRESHOLD:
		return
	
	# code for vfx mostly copied from splash handler
	
	# calculates modifier (1.0 being neutral) for explosion velocity
	var explosion_modifier: float = magnitude * Constants.vfx.BUBBLE_VELOCITY_CONVERTER
	
	# calculates offset for explosion position to account for hitbox radius
	var offset: Vector2 = fish_velocity.normalized() * Constants.vfx.DETECTOR_RADIUS
	
	# creates bubble explosion (direction reversed from velocity)
	bubble_explosion_creator(fish_position - offset, (fish_velocity.normalized() * -1), explosion_modifier)
	
	# code for sfx
	Audiomanager.play_sound(fish_position, Audiomanager.Sound_Type.Plop)




## handles hit related sfx and vfx
func hit_handler(magnitude: float, state: Constants.MovementStates) -> void:
	# underwater bus code
	var bus = "Master"
	if state == Constants.MovementStates.Water:
		bus = "Underwater"
	
	if magnitude > Constants.sfx.HIT_LOUD_THRESHOLD:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Hit_Quiet, bus)
	elif magnitude > Constants.sfx.HIT_MEDIUM_THRESHOLD:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Hit_Medium, bus)
	elif magnitude > Constants.sfx.HIT_QUIET_THRESHOLD:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Hit_Loud, bus)




func boing_handler(fish_velocity: Vector2, fish_position: Vector2, state_type: Constants.MovementStates) -> void:
	
	var bus = "Master"
	if state_type == Constants.StateIdentifiers.Water:
		bus = "Underwater"
	
	var magnitude = fish_velocity.length()
	if magnitude > Constants.sfx.BOING_LOUD_THRESHOLD:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Boing_Loud, bus)
	elif magnitude > Constants.sfx.BOING_MEDIUM_THRESHOLD:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Boing_Medium, bus)
	else:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Boing_Quiet, bus)



## generates bubble explosion particle effects
func bubble_explosion_creator(explosion_position: Vector2, direction:Vector2, velocity_modifier: float) -> void:
	# REWORK BRO
	# GO BACK AND ADD REAL VELOCITY FUNCTIONALITY
 
	var modified_vector:Vector2 = direction
	var weird_vector:Vector3 = Vector3(modified_vector.x, modified_vector.y, 0)
	
	var explosion = Constants.particles.BubbleExplosion.instantiate()
	explosion.process_material.direction = weird_vector
	explosion.position = explosion_position
	
	#print(explosion.process_material.initial_velocity_max)
	#explosion.process_material.initial_velocity_min *= modifier
	#explosion.process_material.initial_velocity_max *= modifier
	#print(explosion.process_material.initial_velocity_max)
	
	explosion.finished.connect(explosion.queue_free)
	
	get_tree().root.add_child(explosion)
	explosion.emitting = true




## swim audio player for animation to call
func audio_swim_player() -> void:
	match moving_machine.current_state.identifier:
		Constants.StateIdentifiers.Water:
			Audiomanager.play_sound(position, Audiomanager.Sound_Type.Swim, "Underwater")
		Constants.StateIdentifiers.Air:
			Audiomanager.play_sound(position, Audiomanager.Sound_Type.Swim)
