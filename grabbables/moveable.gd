## A grabbable object that the player can slide around, but not pick up.
class_name Moveable extends Grabbable


@onready var _joint := $Joint3D as Joint3D


func _exit_tree():
	release()


func grab(by: PhysicsBody3D) -> void:
	_joint.node_a = ^".."
	_joint.node_b = _joint.get_path_to(by)
	_joint.global_transform.origin = by.global_transform.origin
	sleeping = false


func release(_impulse := Vector3.ZERO) -> void:
	_joint.node_a = ^""
	_joint.node_b = ^""
