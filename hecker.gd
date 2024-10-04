extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func KaiperEntered(_body: Node2D) -> void:
	if Dialogic.current_timeline == null:
		var layout = Dialogic.start(Dialogic.VAR.Hecker.HeckerTimeline)
		layout.register_character(load("res://dialogicdata/hecker.dch"), self)


func KaiperExit(body: Node2D) -> void:
	if Dialogic.current_timeline != null:
		for event in Dialogic.current_timeline.events:
			if event is DialogicLabelEvent && event.name == ("leave_"+Dialogic.VAR.LineID):
				Dialogic.Jump.jump_to_label("leave_"+Dialogic.VAR.LineID)


func _on_dialogic_signal(argument:String):
	pass
