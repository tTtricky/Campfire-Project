extends Node2D

@export var burningOutCounter = 0.1

func _ready() -> void:
	$"Burning Out".start()

func _on_burning_out_timeout() -> void:
	if $PointLight2D.energy > 0:
		$PointLight2D.energy -= burningOutCounter;
		$"Burning Out".start()
	print($PointLight2D.energy);
