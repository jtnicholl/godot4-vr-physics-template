class_name Grabbable extends RigidBody3D


@onready var grab_points := $GrabPoints.get_children()


func _ready():
	assert(not grab_points.is_empty(), name + " has no valid grab points")


func grab(_by: PhysicsBody3D) -> void:
	pass


func release(_impulse := Vector3.ZERO) -> void:
	pass
