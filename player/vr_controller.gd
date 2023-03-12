class_name VRController extends XRController3D


@onready var grab_offset := -($GrabRange as Area3D).position

@onready var _mesh := $Mesh as MeshInstance3D
@onready var _grab_range := $GrabRange as Area3D


func show_mesh() -> void:
	_mesh.show()


func hide_mesh() -> void:
	_mesh.hide()


func update_mesh() -> void:
	pass # TODO reimplement


func try_grab(max_distance := INF) -> GrabResult:
	var closest_grabbable: Grabbable = null
	var closest_point: Node3D = null
	var closest_distance := max_distance
	for current_body in _grab_range.get_overlapping_bodies():
		if not (current_body is Grabbable):
			continue
		for current_point in (current_body as Grabbable).grab_points:
			var current_distance := \
					(current_point as Node3D).global_position \
					.distance_squared_to(self.global_position)
			if _compare(current_point, current_distance, closest_point, closest_distance):
				closest_grabbable = current_body
				closest_point = current_point
				closest_distance = current_distance
	return GrabResult.new(closest_grabbable, closest_point)


func _compare(point_a: Node3D, distance_a: float, point_b: Node3D, distance_b: float) -> bool:
	if is_equal_approx(distance_a, distance_b):
		var controller_quat := self.global_transform.basis.get_rotation_quaternion()
		var quat_a := point_a.global_transform.basis.get_rotation_quaternion()
		var quat_b := point_b.global_transform.basis.get_rotation_quaternion()
		return quat_a.angle_to(controller_quat) < quat_b.angle_to(controller_quat)
	elif distance_a < distance_b:
		return true
	else:
		return false


func _on_mesh_update_timer_timeout() -> void:
#	update_mesh()
#	if is_instance_valid(_mesh.mesh):
		$MeshUpdateTimer.queue_free()
