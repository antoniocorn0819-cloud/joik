extends Node

## types of sounds in game
enum Sound_Type {
	Splash_Quiet,
	Splash_Medium,
	Splash_Loud,
	Hit_Quiet,
	Hit_Medium,
	Hit_Loud,
	Swim,
	Checkpoint
}

## dictionary that stores arrays of sounds with keys of sound types
# REPLACE VARIANT MAYBE
const sound_library: Dictionary[Sound_Type, Variant] = {
	Sound_Type.Splash_Quiet: [
		preload("res://Assets/Sounds/Splash/Splash_Quiet-1.wav")
	],
	Sound_Type.Splash_Medium: [
		preload("res://Assets/Sounds/Splash/Splash_Medium-1.wav")
	],
	Sound_Type.Splash_Loud: [
		preload("res://Assets/Sounds/Splash/Splash_Loud-1.wav")
	],
	
	# hit sound effects
	Sound_Type.Hit_Quiet: [
		preload("res://Assets/Sounds/Hit/Hit_Loud-1.wav"),
		preload("res://Assets/Sounds/Hit/Hit_Loud-2.wav"),
		preload("res://Assets/Sounds/Hit/Hit_Loud-3.wav"),
		
	],
	Sound_Type.Hit_Medium: [
		preload("res://Assets/Sounds/Hit/Hit_Medium-1.wav"),
		preload("res://Assets/Sounds/Hit/Hit_Medium-2.wav"),
		preload("res://Assets/Sounds/Hit/Hit_Medium-3.wav"),
		
	],
	Sound_Type.Hit_Loud: [
		preload("res://Assets/Sounds/Hit/Hit_Quiet-1.wav"),
		preload("res://Assets/Sounds/Hit/Hit_Quiet-2.wav"),
		preload("res://Assets/Sounds/Hit/Hit_Quiet-3.wav"),	
	],
	
	Sound_Type.Swim: [
		preload("res://Assets/Sounds/Swim/Swim-1.wav")
	],
	
	Sound_Type.Checkpoint: [
		preload("res://Assets/Sounds/Misc/Checkpoint.wav")
	]
}



func play_sound(audio_position: Vector2, index: Sound_Type, bus: String = "Master") -> void:
	# ADD IN BUS CODE
	if sound_library[index]: # try with .has
		var audio = AudioStreamPlayer2D.new()
		audio.stream = sound_library[index].pick_random()
		audio.bus = bus
		get_tree().root.add_child(audio) # not sure what .root does for it
		audio.global_position = audio_position # still able to access node after adding into tree
		audio.finished.connect(audio.queue_free)
		audio.play()
	else:
		push_error("index does not match with any sound array")
