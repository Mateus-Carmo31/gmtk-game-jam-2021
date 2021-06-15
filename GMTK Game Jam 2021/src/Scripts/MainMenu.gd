extends Control

func _ready():
	
	for i in range(LevelTracker.LEVELS.size()):
		$LevelButtons.get_child(i).connect("pressed", self, "load_level", [i])
		$LevelButtons.get_child(i).connect("pressed", self, "button_click")
	
	for i in range(LevelTracker.LEVELS.size()-1):
		$LevelButtons.get_child(i+1).disabled = !LevelTracker.level_unlocks[i]
	
	if LevelTracker.game_completed:
		$LevelButtons.hide()
		$CreditsButton.hide()
		$EndGameScreen.show()
		
		yield(get_tree().create_timer(5), "timeout")
		
		LevelTracker.game_completed = false
		$LevelButtons.show()
		$CreditsButton.show()
		$EndGameScreen.hide()

func load_level(level_id):
	
	LevelTracker.set_level(level_id)
	
	$AnimationPlayer.play("Exit")
	
	yield($AnimationPlayer, "animation_finished")
	
	get_tree().change_scene("res://src/Scenes/MainGame.tscn")

func button_click():
	$MenuSelectSFX.play()

func toggle_credits():
	pass

func _on_CreditsButton_toggled(button_pressed):
	
	$Credits.visible = button_pressed
	$LevelButtons.visible = !button_pressed
	
	if button_pressed:
		$AnimationPlayer.play("Credits On")
	else:
		$AnimationPlayer.play("Credits Off")
