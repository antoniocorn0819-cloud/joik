extends Area2D

## id of the checkpoint used for both setting and respawning
@export var id: int

# changes label to have id displayed
func _ready():
	$Label.text = str(id)


func _on_body_entered(body):
	# CHANGE IMPLEMENTATION
	if "current_checkpoint_id" in body:
		if body.current_checkpoint_id != id:
			body.current_checkpoint_id = id
		
			# animation handler
			var explosion = Constants.particles.CheckpointExploision.instantiate()
			explosion.finished.connect(explosion.queue_free)
			explosion.position = position
			get_tree().root.add_child(explosion)
			explosion.emitting = true
			
			Audiomanager.play_sound(position, Audiomanager.Sound_Type.Checkpoint)
			
	else:
		print("body does not have checkpoint id")
