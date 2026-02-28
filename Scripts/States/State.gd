extends Node
class_name State

signal Transition

@export var identifier: Constants.StateIdentifiers
@export var default_state: State
var states: Dictionary[Constants.StateIdentifiers, State] = {}
var current_state: State

func _ready():
	for child in get_children():
		if child is State:
			states[child.identifier] = child
			child.Transition.connect(on_child_transition)
	
	if default_state:
		default_state.enter()
		current_state = default_state


func on_child_transition(state: State, request: Constants.StateIdentifiers):
	print("attempting setting:" + str(request))
	# validates authority
	if state != current_state and !current_state:
		print("invalid: basic")
		return
	
	var new_state = states.get(request)
	# state doesn't exist
	if !new_state:
		print("invalid: state doesnt exist")
		return
	
	# checks if current state even exists
	if current_state:
		current_state.exit()
	
	# this was bad
	#new_state.enter()
	current_state = new_state
	# changed to this, fixed problems
	
	# what was happening
	# nested function calls on .enter
	# started by reset call
	# ended with reset call, leading to the reset setter above being called last
	
	
	current_state.enter()
	print("set state to:" + str(current_state.identifier))


func physics(delta):
	if current_state:
		current_state.physics(delta)

func exit():
	pass

func enter():
	pass
