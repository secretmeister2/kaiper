extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func walkspeedchanged(value: float) -> void:
	$Kaiper.walkspeed=value


func runspeedchanged(value: float) -> void:
	$Kaiper.runspeed=value


func standspeedchanged(value: float) -> void:
	$Kaiper.standspeed=value


func horzjumpmultchanged(value: float) -> void:
	$Kaiper.horizjumpmult=value


func horzjumpvertchanged(value: float) -> void:
	$Kaiper.horizjumpvert=value


func vertjumpchanged(value: float) -> void:
	$Kaiper.vertjump=value


func frictionchanged(value: float) -> void:
	$Kaiper.friction=value
