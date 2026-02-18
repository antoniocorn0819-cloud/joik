extends Area2D

@export var id: int
func _ready():
	$Label.text = str(id)

func _on_body_entered(body):
	Master.current_checkpoint_id = id
