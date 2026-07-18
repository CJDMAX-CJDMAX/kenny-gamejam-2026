extends Area2D

signal goat_weight_changed(total_weight: int)

var goat_bodies: Array[Node2D] = []


func _on_body_entered(body: Node2D) -> void:
	if name == "goat_area":
		if not goat_bodies.has(body):
			goat_bodies.append(body)
		if body.has_method("enter_goat_area"):
			body.enter_goat_area()
			$"../../Ui".number += 1
		_emit_goat_weight_changed()
	elif body.has_method("enter_inventory_area"):
		body.enter_inventory_area()


func _on_body_exited(body: Node2D) -> void:
	if name == "goat_area":
		goat_bodies.erase(body)
		if body.has_method("exit_goat_area"):
			body.exit_goat_area()
			$"../../Ui".number -= 1
		_emit_goat_weight_changed()
	elif body.has_method("exit_inventory_area"):
		body.exit_inventory_area()


func _emit_goat_weight_changed() -> void:
	var total_weight := 0
	for body in goat_bodies:
		if not is_instance_valid(body):
			continue
		var body_weight = body.get("weight")
		if body_weight is int or body_weight is float:
			total_weight += int(body_weight)
	goat_weight_changed.emit(total_weight)
