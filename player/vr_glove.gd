class_name VRGlove extends Node3D


var _gripping := false
var _flattened := false

@onready var _tree := $AnimationTree as AnimationTree


func _process(delta: float) -> void:
	var current: float = _tree.get(&"parameters/blend/blend_amount")
	var new: float
	if _gripping:
		new = 1.0
	elif _flattened:
		new = -1.0
	else:
		new = 0.0
	_tree.set(&"parameters/blend/blend_amount", move_toward(current, new, delta * 4.0))


func flatten() -> void:
	_flattened = true


func rest() -> void:
	_flattened = false


func grip() -> void:
	_gripping = true


func release() -> void:
	_gripping = false
