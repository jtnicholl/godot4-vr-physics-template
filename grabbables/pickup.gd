class_name Pickup extends Grabbable


@export var throwable := true

var _holder: Node3D = null
var _collision_shapes := []
@onready var _original_parent := get_parent()


func _ready():
	for current_child in get_children():
		if current_child is CollisionShape3D:
			_collision_shapes.append(current_child)


func _exit_tree():
	assert(_holder == null, name + " was removed from the tree while still being held")


func grab(by: PhysicsBody3D) -> void:
	if is_instance_valid(_holder):
		return
	_reparent_self(by)
	_reparent_shapes(by)
	_holder = by
	freeze = true


func release(impulse := Vector3.ZERO) -> void:
	_holder = null
	_reparent_shapes(self)
	_reparent_self(_original_parent)
	freeze = false
	if throwable:
		apply_central_impulse(impulse)


func _reparent_self(to: Node3D) -> void:
	var original_transform := global_transform
	get_parent().remove_child(self)
	to.add_child(self)
	global_transform = original_transform


func _reparent_shapes(to: Node3D) -> void:
	for current_shape in _collision_shapes:
		var original_transform := (current_shape as CollisionShape3D).global_transform
		current_shape.get_parent().remove_child(current_shape)
		to.add_child(current_shape)
		current_shape.global_transform = original_transform
