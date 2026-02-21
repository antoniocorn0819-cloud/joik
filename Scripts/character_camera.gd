extends CharacterBody2D

# unimportant stuff
const ZOOMINCREMENT: float = 0.05
const ZOOMMAX: float = 1.0
const ZOOMMIN: float = 0.25

const COLISION_VELOCITY_THRESHOLD: float = 200


# states which fish can be in
enum State {
		Water, Air
}

#CHANGE TO INITIAL CHECK
var game_state: State = State.Air

# pixels per second squared
const ACCELERATION: float = 1200.0
const GRAVITY: float = 1200.0
# gets reference to detector child
@onready var detector: Area2D = $"Water Detector"
@onready var camera: Camera2D = $Camera2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var particle_emitter: GPUParticles2D = $GPUParticles2D
@export var checkpointManager: Node


# passes respawn location
# TYPE INDICATIORS
func respawn_handler() -> void:
	position = checkpointManager.death_manager()
	velocity = Vector2(0,0)
	
#stupid shit for sound calculation
var cumulative_velocity_difference: float = 0.0


var pressing: bool = false

func _physics_process(delta: float) -> void:
# move to _input handler
	pressing = Input.is_action_pressed("move")
	
	match game_state:
		State.Water:
			# REWRITE JANK
			if pressing:
				velocity += ACCELERATION * delta * ((get_global_mouse_position() - global_position).normalized())
		State.Air:
			# CHANGE TO CONSTANT
			if not is_on_floor():
				velocity.y += GRAVITY * delta	
	# visual changes
	look_at(get_global_mouse_position())
	# processes physics
	

	var old_velocity_magnitude = get_real_velocity().length()
	
	move_and_slide()
	
	# stupid shit for sound and animation
	# calculates cumuluative change in velocity during collision and passes it to the hit player function
	var velocity_difference = old_velocity_magnitude - get_real_velocity().length()
	if velocity_difference > COLISION_VELOCITY_THRESHOLD:
		cumulative_velocity_difference += velocity_difference
	elif cumulative_velocity_difference > COLISION_VELOCITY_THRESHOLD:
		audio_hit_player(cumulative_velocity_difference, game_state)
		cumulative_velocity_difference = 0.0
	
	animation_handler()



# detects collisions on layer 3 (passthrough layer)
func _on_water_detector_body_entered(body) -> void:
	# checks type of tilemap
	# MAKE SEPERATE FUNCTION
	match body.local_type:
		Master.Type.Water:
			game_state = State.Water
			#water sfx decider
			audio_splash_player(velocity.length())
				
		Master.Type.Reset:
			respawn_handler()



# detects collisions on layer 3 (passthrough layer)
func _on_water_detector_body_exited(body) -> void:
	# if there are no overlapping bodies, fish is in air
	# MAKE SEPERATE FUNCTION
	if !detector.get_overlapping_bodies():
		game_state = State.Air


# detects reset input
func _input(event) -> void:
	if event.is_action_pressed("reset_player"):
		respawn_handler()
	
	# zoom controls
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if camera.zoom.x < ZOOMMAX:
				camera.zoom += Vector2(ZOOMINCREMENT, ZOOMINCREMENT)
			else:
				camera.zoom = Vector2(ZOOMMAX,ZOOMMAX)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if camera.zoom.x > ZOOMMIN:
				camera.zoom -= Vector2(ZOOMINCREMENT, ZOOMINCREMENT)
			else:
				camera.zoom = Vector2(ZOOMMIN,ZOOMMIN)


# self explanitory
func animation_handler() -> void:
	if pressing:
		sprite.animation = "swim"
		if game_state == State.Water:
			particle_emitter.emitting = true
	else:
		sprite.animation = "idle"
		particle_emitter.emitting = false


# really uninmportant values for SFX
const LOUDSPLASH: float = 2400.0
const MEDIUMSPLASH: float = 1200.0

const LOUDHIT: float = 3000.0
const MEDIUMHIT: float = 1500.0
const QUIETHIT: float = 300.0


func audio_splash_player(magnitude: float) -> void:
	if magnitude > LOUDSPLASH:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Splash_Loud)
	elif magnitude > MEDIUMSPLASH:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Splash_Medium)
	else:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Splash_Quiet)


func audio_hit_player(magnitude: float, state: State) -> void:
	# underwater bus code
	var bus = "Master"
	if state == State.Water:
		bus = "Underwater"
	
	if magnitude > LOUDHIT:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Hit_Quiet, bus)
	elif magnitude > MEDIUMHIT:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Hit_Medium, bus)
	elif magnitude > QUIETHIT:
		Audiomanager.play_sound(position, Audiomanager.Sound_Type.Hit_Loud, bus)
