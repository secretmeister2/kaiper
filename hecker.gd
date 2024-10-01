extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func KaiperEntered(_body: Node2D) -> void:
	if Dialogic.current_timeline == null:
		var layout = Dialogic.start("heckertest")
		layout.register_character(load("res://dialogicdata/hecker.dch"), self)
