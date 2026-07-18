extends Node2D


var drag = false
# 鼠标点击与组件原点的相对位置
var mp = Vector2(0, 0)

func _process(delta):
	if drag:
		self.position = get_global_mouse_position() - mp

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			if $sprite.get_rect().has_point(to_local(event.position)):
				drag = true
				mp = event.position - self.position
		elif event.is_released():
			drag = false
