extends Spatial

enum Facing {Left, Right, Up, Down}

onready var current_facing = Facing.Right
var can_move = true

signal tried_to_move(dir)

func _ready():
	pass

func _input(event):
	
	var move_dir
	
	if event.is_action_pressed("move_left"):
		move_dir = Vector3(-1, 0, 0)
	elif event.is_action_pressed("move_right"):
		move_dir = Vector3( 1, 0, 0)
	elif event.is_action_pressed("move_up"):
		move_dir = Vector3( 0, 0,-1)
	elif event.is_action_pressed("move_down"):
		move_dir = Vector3( 0, 0, 1)
	
	if move_dir != null and can_move:
		change_facing(move_dir)
		emit_signal("tried_to_move", move_dir)

func change_facing(dir):
	$Model.rotation = Vector3.DOWN * atan2(dir.z, dir.x)
