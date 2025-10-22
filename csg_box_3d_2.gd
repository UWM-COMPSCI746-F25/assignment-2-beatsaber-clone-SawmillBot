extends CSGBox3D
# Rotation speed in radians per second
@export var spin_speed: float = 2.0

func _process(delta: float) -> void:
	# Rotate around the Y-axis
	rotate_y(spin_speed * delta)
