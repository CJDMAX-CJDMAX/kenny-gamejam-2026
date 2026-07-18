extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if name == "goat_area":
		if body.has_method("enter_goat_area"):
			body.enter_goat_area()
	elif body.has_method("enter_inventory_area"):
		body.enter_inventory_area()


func _on_body_exited(body: Node2D) -> void:
	if name == "goat_area":
		if body.has_method("exit_goat_area"):
			body.exit_goat_area()
	elif body.has_method("exit_inventory_area"):
		body.exit_inventory_area()
