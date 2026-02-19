extends CharacterBody2D

# states which fish can be in
enum State {
		Water, Air
}

#CHANGE TO INITIAL CHECK
var game_state = State.Air

# pixels per second squared
const ACCELERATION = 1200.0

# gets reference to detector child
var detector
func _ready():
	detector = $"Water Detector"
	# connects communication from checkpoint handler
	Master.Respawn.connect(respawn_handler)

# passes respawn location
# TYPE INDICATIORS
func respawn_handler(x, y):
	position = Vector2(x, y)
	velocity = Vector2(0,0)

func _physics_process(delta):
	match game_state:
		State.Water:
			# REWRITE JANK
			if Input.is_action_pressed("move"):
				velocity += ACCELERATION * delta * ((get_global_mouse_position() - global_position).normalized())
		State.Air:
			# CHANGE TO CONSTANT
			if not is_on_floor():
				velocity += get_gravity() * delta	
	# visual changes
	look_at(get_global_mouse_position())
	# processes physics
	move_and_slide()



# detects collisions on layer 3 (passthrough layer)
func _on_water_detector_body_entered(body):
	# checks type of tilemap
	# MAKE SEPERATE FUNCTION
	match body.local_type:
		Master.Type.Water:
			game_state = State.Water
		Master.Type.Reset:
			Master.Death.emit()

# detects collisions on layer 3 (passthrough layer)
func _on_water_detector_body_exited(body):
	# if there are no overlapping bodies, fish is in air
	# MAKE SEPERATE FUNCTION
	if !detector.get_overlapping_bodies():
		game_state = State.Air

# detects reset input
func _input(event):
	if event.is_action_pressed("reset_player"):
		Master.Death.emit()
