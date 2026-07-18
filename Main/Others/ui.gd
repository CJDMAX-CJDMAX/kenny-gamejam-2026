extends Node2D


@export var goat : int
@export var lock : int
@export var now_rate : int
var number : int
var win : bool = false

func _ready() -> void:
	Transition.end_transition()
	$goat/Label.text = str(goat)
	$lock/Label.text = str(lock)
	_update_goat1_weight(0)


func _on_goat_area_weight_changed(total_weight: int) -> void:
	_update_goat1_weight(total_weight)


func _update_goat1_weight(total_weight: int) -> void:
	$goat1/Label2.text = str(total_weight)
func _physics_process(_delta: float) -> void:
	if int($goat1/Label2.text) == goat:
		if number <= lock:
			if win != true:
				win = true
				print("win!!!!")
				Transition.start_transtion()
				var time = get_tree().create_timer(1)
				await time.timeout
				if now_rate ==0:
					get_tree().change_scene_to_file("res://Main/Main_01.tscn")
				elif now_rate ==1:
					get_tree().change_scene_to_file("res://Main/Main_02.tscn")
				elif  now_rate == 2:
					get_tree().change_scene_to_file("res://Main/Main_02.tscn")
			pass
		pass
	pass
