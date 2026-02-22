extends Node


## states for fish movement code
enum MovementStates {
	Water, Air
}

## enumerator for collision detection code
enum CollisionTypes {
	Water, Reset, Bounce
}


# use of variant class allows for variable typing

## constants used for movement calculations
const movement: Dictionary[String, Variant] = {
	# acceleration in pixels per second squared
	"ACCELERATION": 1200.0,
	"GRAVITY": 1200.0,
}

## constants used for input and control
const control: Dictionary[String, Variant] = {
	# constants used for zoom control
	"ZOOM_INCREMENT": Vector2(0.05, 0.05),
	"ZOOM_MAX": 1.0,
	"ZOOM_MIN": 0.25,
}

## constants used for vfx
const vfx: Dictionary[String, Variant] = {
	# constant used to convert player velocity to bubble explosion velocity
	"BUBBLE_VELOCITY_CONVERTER": 500.0,
	
	# constant used to make more accurate exploision origins
	"DETECTOR_RADIUS": 50.0
}

## constants used for sfx
const sfx: Dictionary[String, Variant] = {
	# threshold for change in velocity during a frame to count as a collision
	"COLISION_VELOCITY_THRESHOLD": 200.0,
	
	# constants for velocity thresholds needed to play certian sounds
	
	# for splash
	"SPLASH_LOUD_THRESHOLD": 2400.0,
	"SPLASH_MEDIUM_THRESHOLD": 1200.0,
	
	# for hit
	"HIT_LOUD_THRESHOLD": 3000.0,
	"HIT_MEDIUM_THRESHOLD": 1500.0,
	"HIT_QUIET_THRESHOLD": 300.0
}

## constants of preloaded particle effect scenes
const particles = {
	"BubbleExplosion" = preload("res://Scenes/Particle Effects/BubbleExplosion.tscn"),
	"CheckpointExploision" = preload("res://Scenes/Particle Effects/CheckpointExplosion.tscn")
}
