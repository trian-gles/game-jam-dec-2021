extends AudioStreamPlayer

var white_noise = preload("res://Sounds/white_noise.ogg")
var arrive = preload("res://Sounds/arrive.ogg")
var jump = preload("res://Sounds/jump.ogg")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func play_white_noise():
	volume_db = -11
	stream = white_noise
	play()
	
func play_arrive():
	volume_db = 0
	stream = arrive
	play()
	
func play_jump():
	volume_db = 0
	stream = jump
	play()
	
