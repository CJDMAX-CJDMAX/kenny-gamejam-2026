extends RigidBody2D

var weight : int
var number : int = 1
@export var type : int 
var texture_object : Array[Texture2D] = [load("res://art/assets/Sprites/Tiles/Default/block_empty.png"),
load("res://art/assets/Sprites/Tiles/Default/block_blue.png"),
load("res://art/assets/Sprites/Tiles/Default/block_red.png"),
load("res://art/assets/Sprites/Tiles/Default/block_green.png")
]
var weight_object: Array[int] = [2,5,8,15]
enum ObjectState {
	IN_MARKER,
	DRAGGING,
	FREE_PHYSICS,
	RETURNING_TO_MARKER,
}

@export var marker_object: Marker2D
@export var max_drag_velocity := 4000.0
@export var return_to_marker_y := 1000.0
@export var return_fade_out_time := 0.08
@export var return_fade_in_time := 0.12

var dragging := false
var in_goat_area := false
var grab_offset := Vector2.ZERO
var drag_target_position := Vector2.ZERO
var current_state := ObjectState.IN_MARKER
var return_tween: Tween


func _ready() -> void:
	can_sleep = false
	if type >= 0 and type < weight_object.size():
		weight = weight_object[type]
	if type >= 0 and type < texture_object.size():
		$sprite.texture = texture_object[type]
	$Label.text = str(weight) + "kg"
		
	call_deferred("bind_to_marker", false, false)


func _physics_process(_delta: float) -> void:
	if dragging:
		drag_target_position = get_global_mouse_position() - grab_offset
	elif current_state != ObjectState.RETURNING_TO_MARKER and global_position.y > return_to_marker_y:
		in_goat_area = false
		bind_to_marker(true)


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if current_state == ObjectState.FREE_PHYSICS:
		return

	var new_transform := state.transform
	if current_state == ObjectState.DRAGGING:
		var drag_velocity := (drag_target_position - state.transform.origin) / state.step
		if drag_velocity.length() > max_drag_velocity:
			drag_velocity = drag_velocity.normalized() * max_drag_velocity
		new_transform.origin = drag_target_position
		state.linear_velocity = drag_velocity
	elif current_state == ObjectState.RETURNING_TO_MARKER:
		state.linear_velocity = Vector2.ZERO
	elif marker_object:
		new_transform.origin = marker_object.global_position
		state.linear_velocity = Vector2.ZERO
	state.transform = new_transform
	state.angular_velocity = 0.0


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var mouse_pos := get_global_mouse_position()
			if $sprite.get_rect().has_point($sprite.to_local(mouse_pos)):
				start_drag(mouse_pos)
		elif event.is_released() and dragging:
			stop_drag()


func start_drag(mouse_pos: Vector2) -> void:
	if return_tween:
		return_tween.kill()
	modulate.a = 1.0
	dragging = true
	current_state = ObjectState.DRAGGING
	$Label.visible = true
	grab_offset = mouse_pos - global_position
	drag_target_position = global_position
	custom_integrator = true
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = false
	_wake_sibling_objects()


func stop_drag() -> void:
	drag_target_position = get_global_mouse_position() - grab_offset
	_sync_body_to_position(drag_target_position)
	dragging = false
	$Label.visible = false
	if in_goat_area:
		release_to_physics()
	else:
		bind_to_marker(false)


func bind_to_marker(force := false, animate := true) -> void:
	if marker_object == null:
		return

	if in_goat_area and not force:
		return
	
	if current_state == ObjectState.RETURNING_TO_MARKER:
		return

	dragging = false
	current_state = ObjectState.RETURNING_TO_MARKER
	custom_integrator = true
	$Label.visible = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = false

	if animate:
		await _play_return_to_marker_effect()
	else:
		_sync_body_to_position(marker_object.global_position)
		modulate.a = 1.0

	current_state = ObjectState.IN_MARKER


func release_to_physics() -> void:
	if dragging:
		return

	current_state = ObjectState.FREE_PHYSICS
	custom_integrator = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = false


func enter_inventory_area() -> void:
	if not dragging and not in_goat_area:
		bind_to_marker()


func exit_inventory_area() -> void:
	if not dragging and not in_goat_area:
		release_to_physics()


func enter_goat_area() -> void:
	in_goat_area = true
	if not dragging:
		release_to_physics()


func exit_goat_area() -> void:
	in_goat_area = false


func _sync_body_to_position(target_position: Vector2) -> void:
	var new_transform := global_transform
	new_transform.origin = target_position
	global_transform = new_transform
	PhysicsServer2D.body_set_state(
		get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		new_transform
	)
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = false


func _play_return_to_marker_effect() -> void:
	if return_tween:
		return_tween.kill()

	return_tween = create_tween()
	return_tween.tween_property(self, "modulate:a", 0.0, return_fade_out_time)
	await return_tween.finished

	_sync_body_to_position(marker_object.global_position)

	return_tween = create_tween()
	return_tween.tween_property(self, "modulate:a", 1.0, return_fade_in_time)
	await return_tween.finished


func _wake_sibling_objects() -> void:
	if get_parent() == null:
		return

	for sibling in get_parent().get_children():
		if sibling is RigidBody2D:
			sibling.sleeping = false
			sibling.can_sleep = false
