extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	Master.Death.connect(death_manager)


func death_manager():
	var x
	var y
	for child in get_children():
		if child.id == Master.current_checkpoint_id:
			x = child.position.x
			y = child.position.y
			break
	Master.Respawn.emit(x,y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
