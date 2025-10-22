extends XRController3D
@export var sword_path: NodePath
@export var toggle_action: String

func _process(_dt):
	if Input.is_action_just_pressed(toggle_action):
		var sword = get_node(sword_path)
		if sword:
			sword.toggle()
