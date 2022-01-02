extends AudioStreamPlayer

var white_noise = preload("res://Sounds/white_noise.ogg")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func play_white_noise():
	stream = white_noise
	play()
	
