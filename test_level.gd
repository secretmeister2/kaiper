extends Node2D

func walkspeedchanged(value: float) -> void:
	$Kaiper.stancespeeds["normal"]=value

func runspeedchanged(value: float) -> void:
	$Kaiper.runspeed=value

func standspeedchanged(value: float) -> void:
	$Kaiper.stancespeeds["standing"]=value

func horzjumpmultchanged(value: float) -> void:
	$Kaiper.horizjumpmult=value

func horzjumpvertchanged(value: float) -> void:
	$Kaiper.horizjumpvert=value

func vertjumpchanged(value: float) -> void:
	$Kaiper.vertjump=value

func frictionchanged(value: float) -> void:
	$Kaiper.friction=value
