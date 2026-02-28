extends CharacterState

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


func _physics_process(delta):
	physics(delta)


func _on_detector_body_entered(body):
	body_entered(body)

func _on_detector_body_exited(body):
	body_exited(body)


func _on_detector_area_entered(area):
	area_entered(area)
