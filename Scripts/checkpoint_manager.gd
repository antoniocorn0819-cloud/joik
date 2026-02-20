extends Node


func death_manager() -> Vector2:
	var x
	var y
	for child in get_children():
		if child.id == Master.current_checkpoint_id:
			x = child.position.x
			y = child.position.y
			break
	return Vector2(x,y)
