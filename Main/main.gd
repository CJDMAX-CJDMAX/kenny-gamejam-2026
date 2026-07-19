extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Transition.end_transition()
	if Transition.final_win:
		$Label2.visible = true
		pass
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
