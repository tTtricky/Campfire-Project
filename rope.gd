extends Node2D

##signal climbEntered
##signal climbExited

@export var player : Protagonist

func _ready() -> void:
	##climbEntered.connect(player.ropeEntered)
	#climbExited.connect(player.ropeExited)
	pass

##func _on_line_body_entered(body: Node2D) -> void:
	##if body in get_tree().get_nodes_in_group("Protagonist"):
		##climbEntered.emit()

##func _on_line_body_exited(body: Node2D) -> void:
	##if body in get_tree().get_nodes_in_group("Protagonist"):
		##climbExited.emit()
