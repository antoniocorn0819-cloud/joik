extends Node


# connects death_manager
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
