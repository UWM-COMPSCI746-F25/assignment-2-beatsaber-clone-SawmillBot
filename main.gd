extends Node3D

@export var left_sword_path: NodePath
@export var right_sword_path: NodePath

@onready var left_sword  = get_node_or_null(left_sword_path)
@onready var right_sword = get_node_or_null(right_sword_path)
@onready var sfx: AudioStreamPlayer3D = $XROrigin3D/DestroySFX

func _ready():
	if left_sword and left_sword.has_signal("cube_sliced"):
		left_sword.cube_sliced.connect(_on_cube_sliced)
	if right_sword and right_sword.has_signal("cube_sliced"):
		right_sword.cube_sliced.connect(_on_cube_sliced)

func _on_cube_sliced(cube: Node):
	if sfx and sfx.stream:
		sfx.play()
	if is_instance_valid(cube):
		cube.queue_free()
