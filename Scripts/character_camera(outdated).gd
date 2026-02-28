extends CharacterBody2D

## CHANGE TO INITIAL CHECK
var movement_state: Constants.MovementStates = Constants.MovementStates.Air

## id of current checkpoint for respawning
@export var current_checkpoint_id: int = 1

# references to various child nodes

## stores reference to Area2d needed for non colliding detection
@onready var detector: Area2D = $"Water Detector"

## stores reference to Camera2d needed for changes in zoom
@onready var camera: Camera2D = $Camera2D

## stores reference to AnimationPlayer needed for playing animations
@onready var animator: AnimationPlayer = $AnimationPlayer

## stores reference to GPUParticles2D child which is used for creating the bubble trail
@onready var particle_emitter: GPUParticles2D = $GPUParticles2D


## exports reference to external checkpoint manager
@export var checkpointManager: Node




## variable for collision magnitude detection
var cumulative_velocity_difference: Vector2 = Vector2(0,0)

## variable for input detection
var pressing: bool = false


var collision: KinematicCollision2D

## handles movement code
func _physics_process(delta: float) -> void:
# move to _input handler
	pressing = Input.is_action_pressed("move")
	
	match movement_state:
		Constants.MovementStates.Water:
			# REWRITE JANK
			if pressing:
				velocity += Constants.movement.ACCELERATION * delta * ((get_global_mouse_position() - global_position).normalized())
		Constants.MovementStates.Air:
			if not is_on_floor():
				velocity.y += Constants.movement.GRAVITY * delta	
				
	# visual changes
	look_at(get_global_mouse_position())




	var old_velocity_magnitude = velocity
	
	# processes physics
	move_and_slide()
	
	var velocity_difference = old_velocity_magnitude - velocity
	

	# calculates swim sfx and vfx every frame
	swim_handler()
	
	# collision magnitude detection code only needed for vfx, sfx, and now wall bouncing
	# I would move it, but it is more convenient here
	
	# gets difference in velocity magnitudes before and after frame
	
	 # if the difference is large enough, it is added to the total
	if velocity_difference.length() > Constants.sfx.COLISION_VELOCITY_THRESHOLD:
		cumulative_velocity_difference += velocity_difference
		if get_slide_collision(0) != null:
			collision = get_slide_collision(0)
			
	# if it is not, the cumulative velocity difference is checked, passed to the hit handler, and reset
	elif cumulative_velocity_difference.length() > Constants.sfx.COLISION_VELOCITY_THRESHOLD:
		
		if collision:
			velocity = bounce_calculator(velocity, cumulative_velocity_difference, collision.get_normal(), Constants.movement.WALL_BOUNCE_ELASTICITY)
		hit_handler(cumulative_velocity_difference.length(), movement_state)
		
		cumulative_velocity_difference = Vector2(0,0)
		
		
		
	



## detects entering physics collisions on layer 3 (passthrough layer)
func _on_water_detector_body_entered(body) -> void:
	# checks type of tilemap
	# ADD FAIL CASE TO THIS AND OTHER FUNCTION
	match body.local_type:
		Constants.CollisionTypes.Water:
			movement_state = Constants.MovementStates.Water
			splash_handler(velocity, position)
		Constants.CollisionTypes.Reset:
			respawn_handler()

## detects entering Area2D collisions on layer 3 (passthrrough layer)
func _on_detector_area_entered(area):
	match area.local_type:
		Constants.CollisionTypes.Bounce:
			# temporary solution
			var angle = (2 * area.rotation) - velocity.angle()
			velocity = Vector2.from_angle(angle) * velocity.length()
			
			boing_handler(velocity, position, movement_state )


## detects exiting collisions on layer 3 (passthrough layer)
func _on_water_detector_body_exited(body) -> void:
	# if there are no overlapping bodies, fish is in air
	# MAKE SEPERATE FUNCTION
	if !detector.get_overlapping_bodies():
		movement_state = Constants.MovementStates.Air
		plop_handler(velocity, position)



## detects reset and zoom input and handles zoom calculations


func bounce_calculator(current_velocity: Vector2,
 collision_velocity: Vector2, collision_normal: Vector2,
 collision_elasticity: float, minimum_bounce: float = 0.0) -> Vector2:
	# pretty simple
	var magnitude: float = abs(collision_velocity.dot(collision_normal)) * collision_elasticity
	if magnitude < minimum_bounce:
		return current_velocity
	
	return current_velocity + (collision_normal * magnitude)


func _input(event) -> void:
	if event.is_action_pressed("reset_player"):
		respawn_handler()
	# zoom controls
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if camera.zoom.x < Constants.control.ZOOM_MAX:
				camera.zoom += Constants.control.ZOOM_INCREMENT
			else:
				camera.zoom = Vector2(Constants.control.ZOOM_MAX, Constants.control.ZOOM_MAX)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if camera.zoom.x > Constants.control.ZOOM_MIN:
				camera.zoom -= Constants.control.ZOOM_INCREMENT
			else:
				camera.zoom = Vector2(Constants.control.ZOOM_MIN,Constants.control.ZOOM_MIN)



## respawns player using checkpoint manager
func respawn_handler() -> void:
	position = checkpointManager.death_manager(current_checkpoint_id)
	velocity = Vector2(0,0)


# CODE PAST THIS POINT IS FOR SFX AND VFX

#---------------------------------------------------------------------------------------------------


## handles swim related sfx and vfx
func swim_handler() -> void:
	if pressing:
		animator.current_animation = "swim"
		particle_emitter.emitting = false
		if movement_state == Constants.MovementStates.Water:
			particle_emitter.emitting = true
	else:
		animator.current_animation = "idle"
		particle_emitter.emitting = false



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



func boing_handler(fish_velocity: Vector2, fish_position: Vector2, state: Constants.MovementStates) -> void:
	
	var bus = "Master"
	if state == Constants.MovementStates.Water:
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
	match movement_state:
		Constants.MovementStates.Water:
			Audiomanager.play_sound(position, Audiomanager.Sound_Type.Swim, "Underwater")
		Constants.MovementStates.Air:
			Audiomanager.play_sound(position, Audiomanager.Sound_Type.Swim)
