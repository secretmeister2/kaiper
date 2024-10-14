extends Node
func _ready() -> void:
	$World.hide()
	$World/TestLevel/Kaiper/Camera2D.enabled = false
	$PauseMenu.hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if self.get_tree().paused==false:
			self.get_tree().paused=true
			$World.hide()
			$World/TestLevel/Kaiper/Camera2D.enabled = false
		else:
			self.get_tree().paused=false
			$World.show()
func teststart() -> void:
	$World/TestLevel.process_mode=PROCESS_MODE_INHERIT
	$World.show()
	$MainMenu.hide()
	$PauseMenu.show()
func MainMenuButton() -> void:
	$World.hide()
	$MainMenu.show()
	$PauseMenu.hide()
	self.get_tree().paused=true
