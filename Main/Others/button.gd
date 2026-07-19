extends Button



var true_1 :bool = true
func _on_pressed() -> void:
	if true_1:
		true_1 = false
		$"../AudioStreamPlayer".play()
		Transition.start_transtion()
		var time = get_tree().create_timer(1)
		await time.timeout
		get_tree().change_scene_to_file("res://Main/Main_00.tscn")
		pass # Replace with function body.
