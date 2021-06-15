extends Spatial

const Block = preload("res://src/Scripts/Block.gd")
const Immovable = preload("res://src/Scripts/Immovable.gd")

# Block Map
export(Vector3) var board_size = Vector3(15, 0, 11)
var map = []
var player
onready var slots = get_tree().get_nodes_in_group("slots")

# Entanglement variables
var has_connection = false
var connected_block1 : Spatial = null
var connected_block2 : Spatial = null

# Undo funcionality
class Step:
	var dir_taken : Vector3
	var pushed_block : Spatial
	var entangled_block : Spatial
	
	var player_moved : bool
	var pushed_block_moved : bool
	var entangled_block_moved : bool
	
	func _init():
		self.player_moved = false
		self.pushed_block_moved = false
		self.entangled_block_moved = false

var allow_undo = true
var last_actions = []

signal player_moved(pushed_block)
signal undo
signal level_cleared
signal level_not_cleared
signal level_reset

func _ready():
	
	print("creation")
	
	map.resize(board_size.x * board_size.z)
	
	for block in get_tree().get_nodes_in_group("blocks"):
		map[block.translation.x + block.translation.z * board_size.x] = block
		block.connect("selected", self, "select_block", [block])
	
	for immovable in get_tree().get_nodes_in_group("immovables"):
		map[immovable.translation.x + immovable.translation.z * board_size.x] = immovable
	
	player = get_node("Player")
	
	player.connect("tried_to_move", self, "move_player")

func _input(event):
	
	if event.is_action_pressed("object_clear"):
		
		if connected_block1:
			connected_block1.set_deselected()
			connected_block1 = null
		
		if connected_block2:
			connected_block2.set_deselected()
			connected_block2 = null
		
		has_connection = false
		$SFX/BlockDeselectSFX.play()
	
	if event.is_action_pressed("undo") and allow_undo:
		undo_action()
	
	if event.is_action_pressed("restart"):
		emit_signal("level_reset")
		print("reset")

# Function that moves player. Handles all collision/block push logic
# Since the transmitted block's movement is handled first, you can do some
# wacky shit, like pushing against a wall and it still moving the transmitted block.
# I like it so I'll leave it in.
func move_player(dir):
	
	player.can_move = false
	
	var step = Step.new()
	step.dir_taken = dir
	
	var player_dest : Vector3 = player.translation + dir
	
	# Checks to see if player can move to position
	if can_move_to_pos(player_dest) == false:
		player.can_move = true
		step.player_moved = false
		return
	
	var push_block = get_block(player_dest)
	step.pushed_block = push_block
	
	if push_block:
		
		print("pushed %s" % [push_block])
		var block_dest = push_block.translation + dir
		
		var transmission_block = null
		if push_block == connected_block1:
			transmission_block = connected_block2
		elif push_block == connected_block2:
			transmission_block = connected_block1
		
		step.entangled_block = transmission_block
		
		if transmission_block:
			
			print("transmitted to %s" % [transmission_block])
			var trans_block_dest
			if not transmission_block.invert_direction:
				trans_block_dest = transmission_block.translation + dir
			else:
				trans_block_dest = transmission_block.translation - dir
			
			if can_move_to_pos(trans_block_dest, true):
				move_block(transmission_block.translation, trans_block_dest)
				transmission_block.translation = trans_block_dest
				step.entangled_block_moved = true
				transmission_block.is_in_position = false
		
		# Checks to see if block can be moved. If not, then the player can't, either.
		if can_move_to_pos(block_dest, true) == false:
			player.can_move = true
			step.pushed_block_moved = false
			last_actions.push_front(step) # Logs possible entangled block movement
			update_slots() # Update slots because the entangled block could still have moved
			emit_signal("player_moved", false)
			return
		
		push_block.translation += dir
		move_block(player_dest, block_dest)
		
		push_block.is_in_position = false
		step.pushed_block_moved = true
	
	step.player_moved = true
	
	if step.pushed_block_moved || step.entangled_block_moved:
		emit_signal("player_moved", true)
		$SFX/BlockPushSFX.play()
	else:
		emit_signal("player_moved", false)
		$SFX/PlayerMoveSFX.play()
	
	last_actions.push_front(step)
	
	player.translation += dir
	player.can_move = true
	
	update_slots() # I don't like having to check here every time, there has to be a better way

# Selects a block through a signal. If two blocks are selected already,
# deselects the second and sets the newly clicked one to the first connected_block
func select_block(selected : Block):
	
	if not connected_block1:
		connected_block1 = selected
		selected.set_selected()
		$SFX/BlockSelectSFX.play()
		print_debug("%s\n%s\n%s" % [connected_block1, connected_block2, has_connection])
		return
	
	if not connected_block2 and connected_block1 != selected:
		connected_block2 = selected
		selected.set_selected()
		has_connection = true
		$SFX/BlockSelectSFX.play()
		print_debug("%s\n%s\n%s" % [connected_block1, connected_block2, has_connection])		
		return
	
	if not connected_block2 and connected_block1 == selected:
		return
	
	connected_block1.set_deselected()
	connected_block2.set_deselected()
	selected.set_selected()
	connected_block1 = selected
	connected_block2 = null
	has_connection = false
	
	$SFX/BlockSelectSFX.play()
	
	print_debug("%s\n%s\n%s" % [connected_block1, connected_block2, has_connection])
	

# Undoes action by taking the saved step apart and doing things backwards.
# If it causes issues, REMOVE! No time to debug.
func undo_action():
	if last_actions:
		
		var last_step : Step = last_actions.pop_front()
		print_debug("Dir: %s\nPlayer Moved: %s\nPushed block: %s (%s)\nEntangled block moved: %s (%s)"
		 % [last_step.dir_taken, last_step.player_moved, last_step.pushed_block_moved, last_step.pushed_block,
		last_step.entangled_block_moved, last_step.entangled_block])
		var temp
		
		if last_step.pushed_block_moved:
			temp = last_step.pushed_block.translation - last_step.dir_taken
			
			move_block(last_step.pushed_block.translation, temp)
			last_step.pushed_block.translation = temp
			last_step.pushed_block.is_in_position = false
		
		if last_step.entangled_block_moved:
			temp = last_step.entangled_block.translation
			
			if not last_step.entangled_block.invert_direction:
				temp = last_step.entangled_block.translation - last_step.dir_taken
			else:
				temp = last_step.entangled_block.translation + last_step.dir_taken
			
			move_block(last_step.entangled_block.translation, temp)
			last_step.entangled_block.translation = temp
			last_step.entangled_block.is_in_position = false
		
		if last_step.player_moved:
			player.translation = player.translation - last_step.dir_taken
			player.change_facing(last_step.dir_taken)
			player.can_move = true
		
		if last_step.entangled_block_moved or last_step.pushed_block_moved:
			update_slots()
		
		emit_signal("undo")

# Helper funcion. Set "check_for_normal_blocks" to true if moving towards blocks is illegal
func can_move_to_pos(pos, check_for_normal_blocks = false):
	
	if pos.x < 0 or pos.z < 0 or pos.x > board_size.x-1 or pos.z > board_size.z-1:
		return false
	
	if get_block(pos) is Immovable:
		return false
	
	if check_for_normal_blocks and get_block(pos) is Block:
		return false
	
	return true

# Update block slots and checks if the level has been completed.
# Maybe I should split this into two functions?
func update_slots():
	
	var inactive_slots : int = slots.size()
	for slot in slots:
		var slot_pos = get_block(slot.translation)
		var is_slot_filled = slot_pos is Block
		if(is_slot_filled):
			slot_pos.is_in_position = true
			inactive_slots -= 1
		
		slot.set_state(is_slot_filled)
	
	if inactive_slots == 0:
		print("Level done!")
		player.can_move = false # Player can't move but can undo. Should remember that for the level_completed signal?
		emit_signal("level_cleared")
	else:
		emit_signal("level_not_cleared")

func get_block(pos : Vector3):
	return map[pos.x + pos.z * board_size.x]

func move_block(start : Vector3, dest : Vector3):
	map[dest.x + dest.z * board_size.x] = map[start.x + start.z * board_size.x]
	map[start.x + start.z * board_size.x] = null
