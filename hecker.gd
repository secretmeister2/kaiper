extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func KaiperEntered(_body: Node2D) -> void:
	if Dialogic.current_timeline == null:
		var layout = Dialogic.start(Dialogic.VAR.Hecker.HeckerTimeline)
		layout.register_character(load("res://dialogicdata/hecker.dch"), self)

var hecklatestline="Hello"

func KaiperExit(body: Node2D) -> void:
	Dialogic.end_timeline()
	await get_tree().create_timer(0.1).timeout
	var layout = Dialogic.start(Dialogic.VAR.Hecker.HeckerTimeline, "leave"+ hecklatestline)
	layout.register_character(load("res://dialogicdata/hecker.dch"), self)


func _on_dialogic_signal(argument:String):
	if argument.begins_with("heckerid_"):
		hecklatestline=argument.lstrip("heckerid_")
