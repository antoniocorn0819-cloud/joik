extends Node

#ADD CASE FOR NO CHECKPOINT FOUND
func death_manager(id: int) -> Vector2:
	var checkpoint_position
	for child in get_children():
		if child.id == id:
			checkpoint_position = child.position
			break
	return checkpoint_position
