extends KinematicBody

export var speed = 10
export var acceleration = 5
export var gravity = 0.8
export var jump_power = 30
export var throw_force = 20
export var mouse_sensitivity = 0.1
var last_checkpoint = null
export var friction = 0.5

var camera_x_rotation = 0

var velocity = Vector3()

const Teleport = preload("res://Scenes/Teleport.tscn")

onready var head = $Head
onready var camera = $Head/Camera
onready var throw_position = $Head/ThrowPosition

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))

		var x_delta = event.relative.y * mouse_sensitivity
		if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90: 
			camera.rotate_x(deg2rad(-x_delta))
			camera_x_rotation += x_delta
			
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("left_click"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.is_action_just_pressed("right_click"):
		throw_teleport()
		
		

func _physics_process(delta):
	var movement = false
	
	var head_basis = head.global_transform.basis
	
	var direction = Vector3()
	
	
	
	if Input.is_action_pressed("move_forward"):
		direction -= head_basis.z
		movement = true
	elif Input.is_action_pressed("move_back"):
		direction += head_basis.z
		movement = true
	
	if Input.is_action_pressed("move_left"):
		direction -= head_basis.x
		movement = true
	elif Input.is_action_pressed("move_right"):
		direction += head_basis.x
		movement = true
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y += jump_power
		
	direction = direction.normalized()
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity
	
	
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
	if transform.origin.y < -40:
		die()
		
func throw_teleport():
	var new_teleport: Teleport = Teleport.instance()
	owner.add_child(new_teleport)
	new_teleport.global_transform.origin = throw_position.global_transform.origin
	var head_basis = head.global_transform.basis
	new_teleport.connect("teleport_collided", self, "on_teleport_collision")
	new_teleport.add_force(-head_basis.z * throw_force, new_teleport.global_transform.origin)
		
func on_teleport_collision(pos: Vector3):
	transform.origin = pos
	
func die():
	print("YOU DED")
	if last_checkpoint:
		print(last_checkpoint.name)
		transform.origin = last_checkpoint.respawn_point
	
func save_checkpoint(checkpoint):
	if checkpoint != last_checkpoint:
		last_checkpoint = checkpoint
		print("Saving checkpoint")
	
