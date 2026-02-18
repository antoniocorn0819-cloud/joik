extends CharacterBody2D

enum State {
		Water, Air
}

#change this to an initial check
var game_state = State.Air

const ACCELERATION = 1200.0

func _ready():
	Master.Respawn.connect(respawn_handler)

func _physics_process(delta):
	# Add the gravity.
	match game_state:
		State.Water:
			# Rewrite jank
			if Input.is_action_pressed("ui_accept"):
				velocity += ACCELERATION * delta * ((get_global_mouse_position() - global_position).normalized())
				printt(delta)
		State.Air:
			if not is_on_floor():
				velocity += get_gravity() * delta
	
	look_at(get_global_mouse_position())
	move_and_slide()

func respawn_handler(x, y):
	position = Vector2(x, y)
	velocity = Vector2(0,0)

func _on_water_detector_body_entered(body):
	game_state = State.Water

 
func _on_water_detector_body_exited(body):
	game_state = State.Air

func _input(event):
	if event.is_action_pressed("reset_player"):
		Master.Death.emit()
		print("reset")
