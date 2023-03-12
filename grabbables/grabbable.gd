## A physics object that can be grabbed by the player.
class_name Grabbable extends RigidBody3D


## The grabbable positions on this node.
var grab_points: Array[Node3D] = []


func _ready():
	for current_child in $GrabPoints.get_children():
		assert(current_child is Node3D, "Grab points must extend Node3D")
		grab_points.append(current_child)
	assert(not grab_points.is_empty(), name + " has no valid grab points")


func grab(_by: PhysicsBody3D) -> void:
	pass


func release(_impulse := Vector3.ZERO) -> void:
	pass
