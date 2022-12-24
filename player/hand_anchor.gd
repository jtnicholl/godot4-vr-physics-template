class_name HandAnchor extends CharacterBody3D


@export var controller: NodePath

var offset_position: Vector3

@onready var _controller := get_node(controller) as VRController


func _ready() -> void:
	assert(is_instance_valid(_controller), "Controller path was not set correctly for " + name)


func _physics_process(delta: float) -> void:
	var distance := _controller.to_global(offset_position) - self.global_position
	if distance.length_squared() < 1.0:
		velocity = distance / delta
		move_and_slide()
	else:
		_copy_position()


func _copy_position() -> void:
	self.global_position = _controller.global_position
