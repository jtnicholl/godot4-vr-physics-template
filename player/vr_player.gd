class_name VRPlayer extends Node3D


signal bounds_escaped()

@export var can_move := true
@export var walk_speed := 1.0
@export var impulse_multiplier := 0.2
@export var fall_speed := 1.0

var teleporting_enabled: bool
var continuous_locomotion_enabled: bool
var locomotion_direction_source: Settings.LocomotionDirectionSource
var locomotion_update_mode: Settings.LocomotionUpdateMode

var _left_grabbable: Grabbable = null
var _right_grabbable: Grabbable = null
var _walking_input := Vector2.ZERO
var _locomotion_direction: float

@onready var _body := $CharacterBody3D as CharacterBody3D
@onready var _collision_shape := $CharacterBody3D/CollisionShape3D as CollisionShape3D
@onready var _left_controller := $CharacterBody3D/Origin/LeftController as VRController
@onready var _right_controller := $CharacterBody3D/Origin/RightController as VRController
@onready var _left_hand := $LeftHand as VRHand
@onready var _right_hand := $RightHand as VRHand
@onready var _left_teleporter := $CharacterBody3D/Origin/LeftController/Teleporter as Teleporter
@onready var _right_teleporter := $CharacterBody3D/Origin/RightController/Teleporter as Teleporter
@onready var _camera := $CharacterBody3D/Origin/Camera as XRCamera3D
@onready var _shape := _collision_shape.shape as CapsuleShape3D
@onready var _out_of_bounds_player := $OutOfBoundsPlayer as AnimationPlayer


func _physics_process(_delta: float):
	_update_collision()
	if can_move and continuous_locomotion_enabled and not _walking_input.is_zero_approx():
		if locomotion_update_mode == Settings.LocomotionUpdateMode.CONTINUOUS:
			_update_locomotion_direction()
		var movement := _walking_input.rotated(-_locomotion_direction)
		_body.velocity = Vector3(movement.x, -fall_speed, movement.y) * walk_speed
		_body.move_and_slide()
	elif not _body.is_on_floor():
		_body.velocity = Vector3.DOWN * fall_speed
		_body.move_and_slide()


func position_feet(global_position: Vector3) -> void:
	var camera_offset := _camera.global_position - self.global_position
	_body.position.y = 0.0
	camera_offset.y = 0.0
	global_transform.origin = global_position - camera_offset


func position_head(global_position: Vector3) -> void:
	var camera_offset := _camera.global_transform.origin - global_transform.origin
	global_transform.origin = global_position - camera_offset


func rotate_head(radians: float) -> void:
	var camera_offset := _camera.global_transform.origin - self.global_transform.origin
	var camera_offset_2d := Vector2(camera_offset.x, camera_offset.z)
	var camera_offset_difference := camera_offset_2d - camera_offset_2d.rotated(radians)
	rotate_y(-radians)
	global_translate(Vector3(camera_offset_difference.x, 0.0, camera_offset_difference.y))


func set_hand_offset(position: Vector3, rotation: Vector3) -> void:
	($RightHandAnchor as HandAnchor).offset_position = position
	position.x = -position.x
	($LeftHandAnchor as HandAnchor).offset_position = position
	_right_hand.offset_rotation = Basis.from_euler(rotation)
	rotation.y = -rotation.y
	rotation.z = -rotation.z
	_left_hand.offset_rotation = Basis.from_euler(rotation)


func _update_collision() -> void:
	_collision_shape.position.x = _camera.position.x
	_collision_shape.position.z = _camera.position.z
	_collision_shape.position.y = _camera.position.y / 2.0
	_shape.height = _camera.position.y


func _try_grab(tracker_hand: XRPositionalTracker.TrackerHand) -> void:
	var controller := _left_controller if tracker_hand == \
			XRPositionalTracker.TRACKER_HAND_LEFT else _right_controller
	var hand := _left_hand if tracker_hand == \
			XRPositionalTracker.TRACKER_HAND_LEFT else _right_hand
	var result := controller.try_grab(0.2)
	if result.grabbable != null:
		hand.global_transform = result.grab_point.global_transform
		hand.translate_object_local(controller.grab_offset)
		result.grabbable.grab(hand)
		if tracker_hand == XRPositionalTracker.TRACKER_HAND_LEFT:
			_left_grabbable = result.grabbable
		else:
			_right_grabbable = result.grabbable


func _update_locomotion_direction() -> void:
	match locomotion_direction_source:
		Settings.LocomotionDirectionSource.HEAD:
			_locomotion_direction = _camera.global_transform.basis.get_euler().y
		Settings.LocomotionDirectionSource.LEFT_CONTROLLER:
			_locomotion_direction = _left_controller.global_transform.basis.get_euler().y
		Settings.LocomotionDirectionSource.RIGHT_CONTROLLER:
			_locomotion_direction = _right_controller.global_transform.basis.get_euler().y


func _on_teleport_left_action_pressed():
	if can_move and teleporting_enabled:
		_right_teleporter.cancel()
		_left_teleporter.press()


func _on_teleport_left_action_released():
	_left_teleporter.release()


func _on_teleport_right_action_pressed():
	if can_move:
		_left_teleporter.cancel()
		_right_teleporter.press()


func _on_teleport_right_action_released():
	_right_teleporter.release()


func _on_teleporter_teleported(global_position: Vector3):
	if can_move:
		position_feet(global_position)


func _on_turn_left_action_pressed():
	rotate_head(-PI / 4.0)


func _on_turn_right_action_pressed():
	rotate_head(PI / 4.0)


func _on_grab_left_action_pressed():
	_try_grab.call_deferred(XRPositionalTracker.TRACKER_HAND_LEFT)


func _on_grab_left_action_released():
	if is_instance_valid(_left_grabbable):
		_left_grabbable.release(_left_hand.velocity * impulse_multiplier)
	_left_grabbable = null


func _on_grab_right_action_pressed():
	_try_grab.call_deferred(XRPositionalTracker.TRACKER_HAND_RIGHT)


func _on_grab_right_action_released():
	if is_instance_valid(_right_grabbable):
		_right_grabbable.release(_right_hand.velocity * impulse_multiplier)
	_right_grabbable = null


func _on_bounds_check_body_entered(_body: Node):
	_out_of_bounds_player.play(&"out_of_bounds")


func _on_bounds_check_body_exited(_body: Node):
	_out_of_bounds_player.play(&"RESET")


func _on_out_of_bounds_player_animation_finished(anim_name: StringName):
	if anim_name == &"out_of_bounds":
		emit_signal(&"bounds_escaped")


func _on_controller_input_axis_changed(name: StringName, value: Vector2) -> void:
	if name == &"walk":
		_walking_input = value


func _on_left_controller_button_pressed(name: StringName) -> void:
	if name == &"grab":
		_on_grab_left_action_pressed()
	elif name == &"teleport":
		_on_teleport_left_action_pressed()


func _on_left_controller_button_released(name: StringName) -> void:
	if name == &"grab":
		_on_grab_left_action_released()
	elif name == &"teleport":
		_on_teleport_left_action_released()


func _on_right_controller_button_pressed(name: StringName) -> void:
	if name == &"grab":
		_on_grab_right_action_pressed()
	elif name == &"teleport":
		_on_teleport_right_action_pressed()


func _on_right_controller_button_released(name: StringName) -> void:
	if name == &"grab":
		_on_grab_right_action_released()
	elif name == &"teleport":
		_on_teleport_right_action_released()
