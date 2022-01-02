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

var throw_charging = false
var throw_mult = 1

var is_dying = false

var can_double_jump = false

const teleport = preload("res://Scenes/Teleport.tscn")

onready var head = $Head
onready var camera = $Head/Camera
onready var throw_position = $Head/Camera/ThrowPosition
onready var throw_cursor = $Head/Camera/ThrowPosition/ThrowCursor
onready var death_vision = $Head/Camera/DeathVision
onready var audio = $AudioStreamPlayer
onready var raycasts = $RayCasts

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
		start_charging()
	
	if Input.is_action_just_released("right_click"):
		throw_teleport()
		
	if throw_charging:
		throw_mult += 0.3 * delta
		var curs_scale = throw_mult / 10
		throw_cursor.scale = Vector3(curs_scale, curs_scale, curs_scale)
		print(throw_mult)
		
		

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
	
	
	### JUMP HANDLING
	if not can_double_jump and is_on_floor():
		can_double_jump = true
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y += jump_power
		elif raycasts.check_colliding():
			var ray: RayCast = raycasts.colliding_ray
			velocity += -ray.cast_to * 30
			velocity.y += jump_power
			print("Walljump")
		
		elif can_double_jump:
			velocity.y += jump_power
			can_double_jump = false
		
	direction = direction.normalized()
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity
	
	
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
	
	## HANDLE DYING
	if transform.origin.y < -90:
		die()
	if transform.origin.y < -50:
		if not is_dying:
			is_dying = true
			audio.play_white_noise()
		var new_color = Color(255, 0, 0, (255 + (transform.origin.y + 50)) * 2 )
		death_vision.get_active_material(0).set_albedo(new_color)
	else:
		if is_dying:
			is_dying = false
			audio.stop()	

func start_charging():
	throw_charging = true
	throw_cursor.visible = true
	
		
func throw_teleport():
	var new_teleport = teleport.instance()
	owner.add_child(new_teleport)
	new_teleport.global_transform.origin = throw_position.global_transform.origin
	var direction: Vector3 = throw_position.global_transform.origin - head.global_transform.origin
	direction = direction.normalized()
	new_teleport.connect("teleport_collided", self, "on_teleport_collision")
	new_teleport.add_force(direction * throw_force * throw_mult + velocity, new_teleport.global_transform.origin)
	throw_mult = 1
	throw_charging = false
	throw_cursor.visible = false
	throw_cursor.scale = Vector3(0.1, 0.1, 0.1)
		
func on_teleport_collision(pos: Vector3):
	transform.origin = pos
	
func die():
	print("YOU DED")
	audio.stop()
	if last_checkpoint:
		print(last_checkpoint.name)
		transform.origin = last_checkpoint.respawn_point
		
	var new_color = Color(255, 0, 0, 0)
	death_vision.get_active_material(0).set_albedo(new_color)
	
func save_checkpoint(checkpoint):
	if checkpoint != last_checkpoint:
		last_checkpoint = checkpoint
		print("Saving checkpoint")
		
	
