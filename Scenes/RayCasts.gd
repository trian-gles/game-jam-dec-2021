extends Spatial

var colliding_ray = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func check_colliding():
	for ray in get_children():
		if ray.is_colliding():
			colliding_ray = ray
			return true
	return false
