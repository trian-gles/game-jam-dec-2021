extends RigidBody
class_name Teleport

signal teleport_collided(pos)


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_Teleport_body_entered(body):
	print("Teleport collided with something")
	if body.name == "Player":
		return
	emit_signal("teleport_collided", transform.origin)
	queue_free()
