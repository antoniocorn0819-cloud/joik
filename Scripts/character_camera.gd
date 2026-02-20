extends CharacterBody2D

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
@export var checkpointManager: Node


# passes respawn location
# TYPE INDICATIORS
func respawn_handler() -> void:
	position = checkpointManager.death_manager()
	velocity = Vector2(0,0)

func _physics_process(delta: float) -> void:
	match game_state:
		State.Water:
			# REWRITE JANK
			if Input.is_action_pressed("move"):
				velocity += ACCELERATION * delta * ((get_global_mouse_position() - global_position).normalized())
		State.Air:
			# CHANGE TO CONSTANT
			if not is_on_floor():
				velocity.y += GRAVITY * delta	
	# visual changes
	look_at(get_global_mouse_position())
	# processes physics
	move_and_slide()



# detects collisions on layer 3 (passthrough layer)
func _on_water_detector_body_entered(body) -> void:
	# checks type of tilemap
	# MAKE SEPERATE FUNCTION
	match body.local_type:
		Master.Type.Water:
			game_state = State.Water
		Master.Type.Reset:
			respawn_handler()

# detects collisions on layer 3 (passthrough layer)
func _on_water_detector_body_exited(body)  -> void:
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
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			print("Wheel up")
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			print("Wheel down")
