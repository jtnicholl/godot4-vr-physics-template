class_name VRHand extends RigidBody3D


@export var controller: NodePath

var offset_rotation: Basis
var velocity := Vector3.ZERO

var _time_since_contact := 1.0
var _touching_flat_surface := false

var _previous_position := Vector3.ZERO

@onready var _controller := get_node(controller) as VRController
@onready var _glove := $VRGlove as VRGlove
@onready var _positive_corner := (($Palm as CollisionShape3D).shape as BoxShape3D).size \
		* Vector3(1, -1, 1)


func _ready():
	assert(is_instance_valid(_controller), "Controller path was not set correctly for " + name)


func _physics_process(delta: float):
	velocity = (global_transform.origin - _previous_position) / delta
	_previous_position = global_transform.origin


func _integrate_forces(state: PhysicsDirectBodyState3D):
	if state.get_contact_count() == 0:
		_copy_rotation(state, _time_since_contact) # TODO this does not take delta into account correctly
		_time_since_contact += state.step
		if _time_since_contact >= 0.1:
			_glove.rest.call_deferred()
	else:
		if _contact_is_on_lower_corner(to_local(state.get_contact_collider_position(0))):
			_glove.flatten.call_deferred()
		_time_since_contact = 0.0


func _copy_rotation(state: PhysicsDirectBodyState3D, weight: float) -> void:
	state.transform.basis = state.transform.basis.slerp(
		(_controller.global_transform.basis * offset_rotation).orthonormalized(),
		min(weight, 1.0)
	)
	state.angular_velocity = Vector3.ZERO


func _contact_is_on_lower_corner(local_position: Vector3) -> bool:
	local_position.x = abs(local_position.x)
	local_position.z = abs(local_position.z)
	return is_zero_approx(local_position.distance_squared_to(_positive_corner))
