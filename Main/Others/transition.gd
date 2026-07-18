extends Control



func _ready() -> void:
	pass


func start_transtion():
	var tween = create_tween()
	tween.tween_property($ColorRect.material,"shader_parameter/power",0,1)
	tween.tween_property($ColorRect.material,"shader_parameter/power",30,3)
