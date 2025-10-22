extends RigidBody3D

@export var speed: float = 3.0
@export var max_lifetime: float = 10.0
var _life := 0.0


var cube_color: Color
var color_name: String

func _ready() -> void:
	
	gravity_scale = 0.0
	linear_damp = 0.0
	angular_damp = 0.0

	
	if randi() % 2 == 0:
		cube_color = Color(1, 0, 0)
		color_name = "red"
	else:
		cube_color = Color(0, 0.4, 1)
		color_name = "blue"

	
	set_meta("color_name", color_name)
	add_to_group("cubes")

	
	var mesh := get_node_or_null("MeshInstance3D")
	if mesh:
		if mesh.mesh == null or not (mesh.mesh is BoxMesh):
			var box := BoxMesh.new()
			box.size = Vector3(0.4, 0.4, 0.4)
			mesh.mesh = box

		var mat := StandardMaterial3D.new()
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.albedo_color = cube_color
		mat.emission_enabled = true
		mat.emission = cube_color
		mat.emission_energy_multiplier = 4.0
		mesh.set_surface_override_material(0, mat)

	
	if linear_velocity == Vector3.ZERO:
		var cam := get_viewport().get_camera_3d()
		if cam and cam.is_inside_tree():
			var forward := -cam.global_transform.basis.z
			
			var forward_flat := Vector3(forward.x, 0, forward.z).normalized()
			global_position = cam.global_transform.origin + forward_flat * 6.0
			linear_velocity = -forward_flat * speed
		else:
			global_position = Vector3(0, 1.6, -6)
			linear_velocity = Vector3(0, 0, 1) * speed

func _physics_process(dt: float) -> void:
	_life += dt
	if _life > max_lifetime:
		queue_free()
