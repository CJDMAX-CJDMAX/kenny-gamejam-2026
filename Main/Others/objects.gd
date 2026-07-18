extends RigidBody2D

var weight : int
@export var type : int 
var texture_object : Array[Texture2D] = [load("res://art/assets/Sprites/Tiles/Default/block_empty.png"),
load("res://art/assets/Sprites/Tiles/Default/block_blue.png"),
load("res://art/assets/Sprites/Tiles/Default/block_red.png")
]
var weight_object: Array[int] = [2,5,8]
enum ObjectState {
	IN_MARKER,
	DRAGGING,
	FREE_PHYSICS,
}

@export var marker_object: Marker2D
@export var max_drag_velocity := 4000.0
@export var return_to_marker_y := 1000.0

var dragging := false
var in_goat_area := false
var grab_offset := Vector2.ZERO
var drag_target_position := Vector2.ZERO
var current_state := ObjectState.IN_MARKER


func _ready() -> void:
	can_sleep = false
	if type:
		$sprite.texture = texture_object[type]
		weight = weight_object[type]
		$Label.text = str(weight) + "kg"
		
	call_deferred("bind_to_marker")


func _physics_process(_delta: float) -> void:
	if dragging:
		drag_target_position = get_global_mouse_position() - grab_offset
	elif global_position.y > return_to_marker_y:
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


func bind_to_marker(force := false) -> void:
	if marker_object == null:
		return

	if in_goat_area and not force:
		return

	dragging = false
	current_state = ObjectState.IN_MARKER
	custom_integrator = true
	$Label.visible = false
	_sync_body_to_position(marker_object.global_position)


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


func _wake_sibling_objects() -> void:
	if get_parent() == null:
		return

	for sibling in get_parent().get_children():
		if sibling is RigidBody2D:
			sibling.sleeping = false
			sibling.can_sleep = false
