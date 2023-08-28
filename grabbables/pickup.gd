## A grabbable object that the player can pick up, carry, and potentially throw.
class_name Pickup extends Grabbable


## If [code]true[/code], the player can throw this object, else it always drops straight down when
## released.
@export var throwable := true

var _holder: Node3D = null
var _collision_shapes: Array[CollisionShape3D] = []
@onready var _original_parent := get_parent() as Node3D


func _ready():
	super()
	for current_child in get_children():
		if current_child is CollisionShape3D:
			_collision_shapes.append(current_child)


func _exit_tree():
	assert(_holder == null, name + " was removed from the tree while still being held")


func grab(by: PhysicsBody3D) -> void:
	if is_instance_valid(_holder):
		return
	for current_shape in _collision_shapes:
		current_shape.reparent(by)
	reparent(by)
	_holder = by
	freeze = true


func release(impulse := Vector3.ZERO) -> void:
	_holder = null
	reparent(_original_parent)
	for current_shape in _collision_shapes:
		current_shape.reparent(self)
	freeze = false
	if throwable:
		apply_central_impulse(impulse)
