extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body in get_tree().get_nodes_in_group("Protagonist") and $Sprite2D.texture != load('res://Bad torch unlit.png'):
		body.gainTorch(1)
		
		$Sprite2D.texture = load('res://Bad torch unlit.png')
		$PointLight2D.energy = 0.3
