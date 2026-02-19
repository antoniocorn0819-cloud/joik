extends Node

enum Type {
	Air, Reset
}

var current_checkpoint_id = 0

signal Death
signal Respawn
