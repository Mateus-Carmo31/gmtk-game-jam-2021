extends Camera

export(Vector2) var max_offset = Vector2(3, 1)
export var decay = 0.6
var trauma = 0

func _process(delta):
	
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func set_trauma(amount : float):
	trauma = min(amount, 1)

func add_trauma(amount : float):
	print("Applied ", amount, " to trauma!")
	trauma = min(trauma + amount, 1)

func shake():
	var amount = trauma * trauma
	h_offset = max_offset.x * amount * rand_range(-1, 1)
	v_offset = max_offset.y * amount * rand_range(-1, 1)
