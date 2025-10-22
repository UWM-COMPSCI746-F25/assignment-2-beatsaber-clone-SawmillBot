extends Node3D

@export var cube_scene: PackedScene
@export var spawn_distance: float = 6.0       
@export var cube_speed: float = 3.0           
@export var lateral_range: float = 0.8        
@export var vertical_min: float = -0.1        
@export var vertical_max: float = 0.2       
@export var spawn_interval_min: float = 0.5
@export var spawn_interval_max: float = 2.0

func _ready() -> void:
	randomize()
	_spawn_loop()

func _spawn_loop() -> void:
	while true:
		var wait_time = randf_range(spawn_interval_min, spawn_interval_max)
		await get_tree().create_timer(wait_time).timeout
		_spawn_one()

func _spawn_one() -> void:
	if cube_scene == null:
		push_error("CubeSpawner: No cube scene assigned!")
		return

	var cam := get_viewport().get_camera_3d()
	if cam == null or not cam.is_inside_tree():
		push_warning("CubeSpawner: Camera not found, skipping spawn.")
		return

	var origin: Vector3 = cam.global_transform.origin
	var fwd: Vector3 = -cam.global_transform.basis.z
	var forward_flat := Vector3(fwd.x, 0.0, fwd.z).normalized()   # flatten forward vector
	var right: Vector3 = cam.global_transform.basis.x.normalized()
	var up: Vector3 = Vector3.UP

	# Choose random horizontal/vertical offset around head height
	var off_x := randf_range(-lateral_range, lateral_range)
	var off_y := randf_range(vertical_min, vertical_max)

	# Position cube relative to player
	var pos := origin + forward_flat * spawn_distance + right * off_x + up * off_y

	# Set its velocity straight toward player
	var vel := -forward_flat * cube_speed

	var cube: Node3D = cube_scene.instantiate()
	cube.global_position = pos

	# If it's a RigidBody3D, apply velocity
	if cube is RigidBody3D:
		cube.linear_velocity = vel
	elif cube.has_method("set_linear_velocity"):
		cube.call("set_linear_velocity", vel)

	# Add to current scene
	get_tree().current_scene.add_child(cube)

	print("[CubeSpawner] Spawned @ ", pos, " vel=", vel)
