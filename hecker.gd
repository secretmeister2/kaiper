extends Node2D

signal KaiperEnteredHeck
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func KaiperEntered(body: Node2D) -> void:
	if Dialogic.current_timeline == null:
		Dialogic.start("heckertest")
