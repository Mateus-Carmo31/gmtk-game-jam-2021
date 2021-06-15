extends Spatial

const BLOCK_INACTIVE = preload("res://assets/Mats/BlockInactive.tres")
const BLOCK_ACTIVE   = preload("res://assets/Mats/BlockActive.tres")

var is_active = false

func set_state(state):
	
	if state:
		$Slot.set_surface_material(0, BLOCK_ACTIVE)
	else:
		$Slot.set_surface_material(0, BLOCK_INACTIVE)
