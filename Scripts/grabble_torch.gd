extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body in get_tree().get_nodes_in_group("Protagonist"):
		body.gainTorch(1)
		queue_free()
