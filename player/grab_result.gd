class_name GrabResult extends RefCounted


var grabbable: Grabbable
var grab_point: Node3D


func _init(grabbable: Grabbable, grab_point: Node3D) -> void:
	self.grabbable = grabbable
	self.grab_point = grab_point
