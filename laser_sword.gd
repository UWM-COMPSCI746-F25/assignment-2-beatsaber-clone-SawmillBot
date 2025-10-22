extends Area3D

signal cube_sliced(cube: Node)

const RED  : Color = Color(1, 0, 0)
const BLUE : Color = Color(0, 0.4, 1)

@export var sword_color: Color = BLUE          # set per instance (left=red, right=blue)
@export var blade_length: float = 1.0          # meters along -Z
@export var blade_thickness: float = 0.02      # meters (X/Y)
var is_on: bool = true

@onready var blade: MeshInstance3D   = $Blade
@onready var col  : CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	# Ensure nodes exist
	if blade == null:
		push_error("LaserSword: missing child 'Blade' (MeshInstance3D).")
		return
	if col == null:
		push_error("LaserSword: missing child 'CollisionShape3D'.")
		return

	# Geometry + collider
	_ensure_blade_geometry()
	_ensure_collider()

	# Emissive, unshaded material
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = sword_color
	mat.emission_enabled = true
	mat.emission = sword_color
	mat.emission_energy_multiplier = 3.0
	blade.set_surface_override_material(0, mat)

	_apply_on_off()

	# Detect rigid bodies entering (cubes are RigidBody3D)
	connect("body_entered", _on_body_entered)

func toggle() -> void:
	is_on = !is_on
	_apply_on_off()

func _apply_on_off() -> void:
	blade.visible = is_on
	col.disabled = not is_on
	monitoring = is_on

func _on_body_entered(body: Node) -> void:
	if not is_on:
		return
	# Only handle cubes (RigidBody3D) in "cubes" group
	if not (body is RigidBody3D):
		return
	if not body.is_in_group("cubes"):
		return

	# Cube color from metadata
	if not body.has_meta("color_name"):
		return
	var cube_color_name := str(body.get_meta("color_name"))

	# Sword’s color name
	var sword_name := _sword_color_name()

	# Destroy only on color match
	if cube_color_name == sword_name:
		# Prefer signaling to Main.gd so it can play SFX, then free
		if has_signal("cube_sliced"):
			emit_signal("cube_sliced", body)
		else:
			if is_instance_valid(body):
				body.queue_free()

func _sword_color_name() -> String:
	if sword_color.is_equal_approx(RED):
		return "red"
	if sword_color.is_equal_approx(BLUE):
		return "blue"
	# Fallback: whichever named color is closer in RGB space
	var red_dist  = _color_distance(sword_color, RED)
	var blue_dist = _color_distance(sword_color, BLUE)
	return "red" if red_dist < blue_dist else "blue"

func _color_distance(a: Color, b: Color) -> float:
	return sqrt(pow(a.r - b.r, 2) + pow(a.g - b.g, 2) + pow(a.b - b.b, 2))

func _ensure_blade_geometry() -> void:
	# Create a BoxMesh if missing; 1m along -Z, centered at -length/2
	if blade.mesh == null or not (blade.mesh is BoxMesh):
		blade.mesh = BoxMesh.new()
	var bm := blade.mesh as BoxMesh
	bm.size = Vector3(blade_thickness, blade_thickness, blade_length)
	blade.position = Vector3(0, 0, -blade_length * 0.5)
	blade.rotation = Vector3.ZERO

func _ensure_collider() -> void:
	if col.shape == null or not (col.shape is BoxShape3D):
		col.shape = BoxShape3D.new()
	var bs := col.shape as BoxShape3D
	bs.size = Vector3(blade_thickness, blade_thickness, blade_length)
	col.position = Vector3(0, 0, -blade_length * 0.5)
	col.rotation = Vector3.ZERO
