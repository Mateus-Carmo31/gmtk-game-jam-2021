extends Area

const BLOCK_INACTIVE = preload("res://assets/Mats/BlockInactive.tres")
const BLOCK_ACTIVE   = preload("res://assets/Mats/BlockActive.tres")

# Does the transmission movement impact the sender's as well?
export var transmission_blocks_movement = false 

# Does the transmission direction get inverted?
export var invert_direction = false

var is_in_position = false

signal selected

func _on_Block_input_event(camera, event, click_position, click_normal, shape_idx):
	
	if event.is_action_pressed("object_select"):
		emit_signal("selected")

func _process(delta):
	
	if is_in_position:
		
		$MeshInstance.set_surface_material(1, BLOCK_ACTIVE)
		
		# There has to be a better way to do this...
		$MeshInstance.rotation_degrees.x = wrapf($MeshInstance.rotation_degrees.x + 0.5, 0, 360)
		$MeshInstance.rotation_degrees.y = wrapf($MeshInstance.rotation_degrees.y + 2.1, 0, 360)
		$MeshInstance.rotation_degrees.z = wrapf($MeshInstance.rotation_degrees.z + 0.4, 0, 360)
	else:
		
		$MeshInstance.set_surface_material(1, BLOCK_INACTIVE)
		
		var cur = Quat($MeshInstance.transform.basis)
		var dest = Quat(Transform.IDENTITY.basis)
		
		$MeshInstance.transform.basis = Basis(cur.slerp(dest, delta * 2.0))


func set_selected():
	$MeshInstance.set_surface_material(2, BLOCK_ACTIVE)

func set_deselected():
	$MeshInstance.set_surface_material(2, BLOCK_INACTIVE)
