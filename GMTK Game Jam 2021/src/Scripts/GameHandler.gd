extends Spatial

var steps_taken = 0

func _ready():
	
	$UI.hide()
	
	var level = LevelTracker.get_current_level().instance()
	$UI/LevelID.text = "0" + str(LevelTracker.current_level_id) if LevelTracker.current_level_id < 10 else str(LevelTracker.current_level_id)
	
	level.connect("level_cleared", self, "clear_level")
	level.connect("level_not_cleared", self, "unclear_level")
	
	# Setting this one as deferred because this involves freeing the level
	# and we should defer the freeing until the idle frame to avoid issues
	level.connect("level_reset", self, "restart_level", [], 0 | CONNECT_DEFERRED)
	level.connect("player_moved", self, "player_action", [true])
	level.connect("undo", self, "player_action", [false, false])
	
	add_child_below_node($UI, level)
	level.translation = Vector3(0, -16, 0)
	
	animate_entry(true)

# Deletes the current level and re-instantiates it
func restart_level():
	
	if not $Tween.is_active():
		
		$ResetLevelSFX.play()
	
		animate_exit()
		yield($Tween, "tween_all_completed")
		
		var level = LevelTracker.get_current_level().instance()
		$UI/LevelID.text = "0" + str(LevelTracker.current_level_id) if LevelTracker.current_level_id < 10 else str(LevelTracker.current_level_id)
		
		get_child(1).free()
		
		level.connect("level_cleared", self, "clear_level")
		level.connect("level_not_cleared", self, "unclear_level")
		level.connect("level_reset", self, "restart_level", [], 0 | CONNECT_DEFERRED)
		level.connect("player_moved", self, "player_action", [true])
		level.connect("undo", self, "player_action", [false, false])
		
		level.translation = Vector3(0, -16, 0)
		
		add_child_below_node($UI, level)
		unclear_level()
		
		steps_taken = 0
		$UI/StepsTaken.text = "00"
		
		animate_entry()

func go_to_next_level():
	
	$LevelCompletedSFX.play()
	
	unclear_level()
	
	animate_exit()
	
	yield($Tween, "tween_all_completed")
	
	get_child(1).free()
	
	LevelTracker.set_current_level_completed(true)
	
	if(LevelTracker.progress_level() == false):
		return_to_main_menu(false)
		return
	
	var level = LevelTracker.get_current_level().instance()
	$UI/LevelID.text = "0" + str(LevelTracker.current_level_id) if LevelTracker.current_level_id < 10 else str(LevelTracker.current_level_id)
	
	level.connect("level_cleared", self, "clear_level")
	level.connect("level_not_cleared", self, "unclear_level")
	level.connect("level_reset", self, "restart_level", [], 0 | CONNECT_DEFERRED)
	level.connect("player_moved", self, "player_action", [true])
	level.connect("undo", self, "player_action", [false, false])
	
	level.translation = Vector3(0, -16, 0)
	add_child_below_node($UI, level)
	
	steps_taken = 0
	$UI/StepsTaken.text = "00"
	
	animate_entry()

func clear_level():
	$UI/NextLevel.show()

func unclear_level():
	$UI/NextLevel.hide()

# Arguments are inversed because of signal trickery I'm too lazy to rework. Sorry
func player_action(block_was_pushed, moved):
	
	if moved:
		if(block_was_pushed):
			$Camera.set_trauma(0.15)
		
		steps_taken += 1
		$UI/StepsTaken.text = "0" + str(steps_taken) if steps_taken < 10 else str(steps_taken)
	
	else:
		steps_taken -= 1
		$UI/StepsTaken.text = "0" + str(steps_taken) if steps_taken < 10 else str(steps_taken)

func animate_entry(include_ui = false):
	
	$Tween.interpolate_property(
		get_child(1), 
		"translation", 
		Vector3(0, -16, 0), Vector3(0,0,0), 
		1.5,
		Tween.TRANS_SINE, Tween.EASE_OUT
	)
	
	$Tween.start()
	
	yield($Tween, "tween_completed")
	
	if include_ui:
		
		$UI.rect_position = Vector2(-158, 0)
		$UI.rect_size = Vector2(1660, 724)
		
		$Tween.interpolate_property(
			$UI,
			"rect_position",
			Vector2(-158, 0), Vector2(0,0),
			1,
			Tween.TRANS_SINE, Tween.EASE_OUT
		)
		
		$Tween.interpolate_property(
			$UI,
			"rect_size",
			Vector2(1660, 724), Vector2(1280,724),
			1,
			Tween.TRANS_SINE, Tween.EASE_OUT
		)
	
	$Tween.start()
	$UI.show()

func animate_exit(include_ui = false, include_audio = false):
	
	$Tween.interpolate_property(
		get_child(1), 
		"translation", 
		Vector3(0,0,0), Vector3(0, -16, 0), 
		1.5,
		Tween.TRANS_SINE, Tween.EASE_OUT
	)
	
	if include_ui:
		
		$UI.rect_position = Vector2(0,0)
		$UI.rect_size = Vector2(1280,724)
		
		$Tween.interpolate_property(
			$UI,
			"rect_position",
			Vector2(0,0), Vector2(-158, 0), 
			1,
			Tween.TRANS_SINE, Tween.EASE_OUT
		)
		
		$Tween.interpolate_property(
			$UI,
			"rect_size",
			Vector2(1280,724), Vector2(1660, 724), 
			1,
			Tween.TRANS_SINE, Tween.EASE_OUT
		)
	
	if include_audio:
		
		$Tween.interpolate_property(
			$GameMusic, "volume_db",
			-5, -80, 0.9,
			Tween.TRANS_SINE, Tween.EASE_IN
		)
	
	
	$Tween.start()

func return_to_main_menu(play_sfx = true):
	
	if play_sfx:
		$ReturnSFX.play()
	
	animate_exit(true, true)
	yield($Tween, "tween_all_completed")
	get_tree().change_scene("res://src/Scenes/MainMenu.tscn")
