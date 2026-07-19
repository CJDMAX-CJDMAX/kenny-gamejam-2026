extends Area2D

signal goat_weight_changed(total_weight: int, special_weight_text: String)

var goat_bodies: Array[Node2D] = []


func _on_body_entered(body: Node2D) -> void:
	if name == "goat_area":
		var is_new_body := not goat_bodies.has(body)
		if is_new_body:
			goat_bodies.append(body)
		if is_new_body and body.has_method("enter_goat_area"):
			body.enter_goat_area()
			$"../../Ui".number += _get_body_weight_count(body)
		_emit_goat_weight_changed()
	elif body.has_method("enter_inventory_area"):
		body.enter_inventory_area()


func _on_body_exited(body: Node2D) -> void:
	if name == "goat_area":
		var was_body := goat_bodies.has(body)
		goat_bodies.erase(body)
		if was_body and body.has_method("exit_goat_area"):
			body.exit_goat_area()
			$"../../Ui".number -= _get_body_weight_count(body)
		_emit_goat_weight_changed()
	elif body.has_method("exit_inventory_area"):
		body.exit_inventory_area()


func _emit_goat_weight_changed() -> void:
	var area_weight_count := _get_area_weight_count()
	var base_weight := _get_base_total_weight()
	var total_weight := base_weight
	var special_weight_texts: Array[String] = []
	for body in goat_bodies:
		if not is_instance_valid(body):
			continue
		if not _is_special_weight_body(body):
			continue
		if body.has_method("get_effective_weight"):
			total_weight += body.get_effective_weight(area_weight_count, base_weight)
		if body.has_method("get_special_weight_text"):
			var special_text: String = body.get_special_weight_text(area_weight_count, base_weight)
			if special_text != "":
				special_weight_texts.append(special_text)
	goat_weight_changed.emit(total_weight, "\n".join(PackedStringArray(special_weight_texts)))


func _get_area_weight_count() -> int:
	var total_count := 0
	for body in goat_bodies:
		if not is_instance_valid(body):
			continue
		total_count += _get_body_weight_count(body)
	return total_count


func _get_body_weight_count(body: Node2D) -> int:
	if body.has_method("get_weight_count"):
		return body.get_weight_count()
	var body_number = body.get("number")
	if body_number is int or body_number is float:
		return int(body_number)
	return 1


func _get_base_total_weight() -> int:
	var total_weight := 0
	for body in goat_bodies:
		if not is_instance_valid(body) or _is_special_weight_body(body):
			continue
		var body_weight = body.get("weight")
		if body_weight is int or body_weight is float:
			total_weight += int(body_weight)
	return total_weight


func _is_special_weight_body(body: Node2D) -> bool:
	if body.has_method("is_special_weight"):
		return body.is_special_weight()
	return false
