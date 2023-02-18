class_name Teleporter extends RayCast3D


signal teleported(global_position: Vector3)

const _OK_TELEPORT_COLOR = Color.AQUAMARINE
const _NO_TELEPORT_COLOR = Color.ORANGE_RED

@export_range(1.0, 10.0, 1.0) var max_distance := 5.0

@onready var _collision_check := $CollisionCheck as Area3D
@onready var _target := $CollisionCheck/Target as MeshInstance3D


func _ready() -> void:
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if is_colliding():
		_collision_check.global_position = get_collision_point()
		_collision_check.global_transform.basis = Basis.IDENTITY
		_collision_check.show()
		_target.set_instance_shader_parameter(
			&"current_color",
			_OK_TELEPORT_COLOR if _can_teleport() else _NO_TELEPORT_COLOR
		)
	else:
		_collision_check.hide()


func press() -> void:
	enabled = true
	set_physics_process(true)


func release() -> void:
	if enabled and _can_teleport():
		teleported.emit(get_collision_point())
	_stop()


func cancel() -> void:
	_stop()


func _stop() -> void:
	set_physics_process(false)
	enabled = false
	_collision_check.hide()


func _can_teleport() -> bool:
	return is_colliding() and \
			_collision_check.get_overlapping_bodies().is_empty() and \
			global_position.distance_to(get_collision_point()) <= max_distance
