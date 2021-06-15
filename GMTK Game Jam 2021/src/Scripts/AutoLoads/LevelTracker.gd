extends Node

const LEVELS = [
	preload("res://src/Scenes/Levels/Level0.tscn"),
	preload("res://src/Scenes/Levels/Level1.tscn"),
	preload("res://src/Scenes/Levels/Level2.tscn"),
	preload("res://src/Scenes/Levels/Level3.tscn"),
	preload("res://src/Scenes/Levels/Level4.tscn"),
	preload("res://src/Scenes/Levels/Level5.tscn"),
	preload("res://src/Scenes/Levels/Level6.tscn"),
	preload("res://src/Scenes/Levels/Level7.tscn"),
	preload("res://src/Scenes/Levels/Level8.tscn"),
	preload("res://src/Scenes/Levels/Level9.tscn"),
	preload("res://src/Scenes/Levels/Level10.tscn"),
	preload("res://src/Scenes/Levels/Level11.tscn"),
	preload("res://src/Scenes/Levels/Level12.tscn"),
	preload("res://src/Scenes/Levels/Level13.tscn"),
	preload("res://src/Scenes/Levels/Level14.tscn")
]

var level_unlocks := [] # Should rename to "level_complete_list"

var current_level_id = 0
var game_completed = false

func _ready():
	
	level_unlocks.resize(LEVELS.size())
	
	for i in range(LEVELS.size()):
		level_unlocks[i] = false

func get_current_level():
	return LEVELS[current_level_id]

func set_level(id):
	current_level_id = id

func set_current_level_completed(completed):
	level_unlocks[current_level_id] = completed

func progress_level():
	current_level_id += 1
	if current_level_id == LEVELS.size():
		game_completed = true
		return false
	else:
		return true

