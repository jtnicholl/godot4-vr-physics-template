class_name VRPlayer extends Node3D


## Emitted when the player has his or her head within a wall for 1.2 seconds.
signal bounds_escaped()

## If [code]true[/code], the player is currently allowed to move.[br]
## This affects both walking and teleporting. Use it to freeze the player in one spot.
@export var can_move := true
## The player's walking speed when using continuous locomotion, in meters per second.
@export_range(0.1, 5.0, 0.1, "or_greater", "hide_slider") var walk_speed := 1.0
## Multiplier for how hard the player can throw a held [Pickup].
@export_range(0.0, 2.0, 0.05, "or_greater", "hide_slider") var impulse_multiplier := 0.2
## How fast the player falls after walking off a ledge using continuous locomotion.[br]
## This is a continuous speed without acceleration, unaffected by gravity settings. This helps
## minimize VR-induced motion sickness.
@export_range(0.1, 5.0, 0.1, "or_greater", "hide_slider") var fall_speed := 1.0

## If [code]true[/code], the player can teleport.
var teleporting_enabled: bool
## If [code]true[/code], the player can walk.
var continuous_locomotion_enabled: bool:
	get:
		return continuous_locomotion_enabled
	set(value):
		continuous_locomotion_enabled = value
		if not value:
			_walking = false
## The source used for walking direction (Relative to the head, left hand, or right hand).
var locomotion_direction_source: Settings.LocomotionDirectionSource
## Whether turning the direction source after starting to walk should change walking direction, or
## if the player is required to stop and start walking again.
var locomotion_update_mode: Settings.LocomotionUpdateMode
## If [code]true[/code], the player turns every frame while holding a turn input, instead of once
## upon pressing the input.
var smooth_turning := false

var _walk_require_press := false
var _turn_require_press := false
var _left_grabbable: Grabbable = null
var _right_grabbable: Grabbable = null
var _walking_input := Vector2.ZERO
var _turning_input := 0.0
var _locomotion_direction: float
var _walking := false
var _turning := false

@onready var _body := $CharacterBody3D as CharacterBody3D
@onready var _collision_shape := $CharacterBody3D/CollisionShape3D as CollisionShape3D
@onready var _left_controller := $CharacterBody3D/Origin/LeftController as VRController
@onready var _right_controller := $CharacterBody3D/Origin/RightController as VRController
@onready var _left_hand := $LeftHand as VRHand
@onready var _right_hand := $RightHand as VRHand
@onready var _left_glove := $LeftHand/VRGlove as VRGlove
@onready var _right_glove := $RightHand/VRGlove as VRGlove
@onready var _left_teleporter := $CharacterBody3D/Origin/LeftController/Teleporter as Teleporter
@onready var _right_teleporter := $CharacterBody3D/Origin/RightController/Teleporter as Teleporter
@onready var _camera := $CharacterBody3D/Origin/Camera as XRCamera3D
@onready var _shape := _collision_shape.shape as CapsuleShape3D
@onready var _out_of_bounds_player := $OutOfBoundsPlayer as AnimationPlayer


func _physics_process(delta: float) -> void:
	_update_collision()
	if can_move and (_walking or not _walk_require_press) and not _walking_input.is_zero_approx():
		if locomotion_update_mode == Settings.LocomotionUpdateMode.CONTINUOUS:
			_update_locomotion_direction()
		var movement := _walking_input.rotated(-_locomotion_direction)
		_body.velocity = Vector3(movement.x, -fall_speed, movement.y) * walk_speed
		_body.move_and_slide()
	elif not _body.is_on_floor():
		_body.velocity = Vector3.DOWN * fall_speed
		_body.move_and_slide()
	if smooth_turning and (_turning or not _turn_require_press):
		smooth_turn(_turning_input * delta)


## Position the player with their feet at [param global_position].
func position_feet(global_position: Vector3) -> void:
	var camera_offset := _camera.global_position - self.global_position
	_body.position.y = 0.0
	camera_offset.y = 0.0
	self.global_position = global_position - camera_offset


## Position the player with their head at [param global_position].
func position_head(global_position: Vector3) -> void:
	var camera_offset := _camera.global_position - global_position
	self.global_position = global_position - camera_offset


## Rotate the player [param radians] clockwise (positive values to the player's right).[br]
## This turns the root node, do not call it every frame.
func snap_turn(radians: float) -> void:
	var camera_offset := _camera.global_position - self.global_position
	var camera_offset_2d := Vector2(camera_offset.x, camera_offset.z)
	var camera_offset_difference := camera_offset_2d - camera_offset_2d.rotated(radians)
	rotate_y(-radians)
	global_translate(Vector3(camera_offset_difference.x, 0.0, camera_offset_difference.y))


## Rotate the player [param radians] clockwise (positive values to the player's right).[br]
## This turns only the player's body, making it acceptable to call every frame.
func smooth_turn(radians: float) -> void:
	var camera_offset := _camera.position
	var camera_offset_2d := Vector2(camera_offset.x, camera_offset.z)
	var camera_offset_difference := camera_offset_2d - camera_offset_2d.rotated(radians)
	_body.rotate_y(-radians)
	_body.translate(Vector3(camera_offset_difference.x, 0.0, camera_offset_difference.y))


## Apply the given [param controller_settings] to this player.
func set_controller_settings(controller_settings: ControllerSettings) -> void:
	_set_hand_offset(controller_settings.hand_offset_position, controller_settings.hand_offset_rotation)
	_walk_require_press = controller_settings.walk_require_press
	_turn_require_press = controller_settings.turn_require_press
	_left_controller.pose = controller_settings.pose
	_right_controller.pose = controller_settings.pose


func _set_hand_offset(position: Vector3, rotation: Vector3) -> void:
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
	_collision_shape.position.y = _camera.position.y / 2.0 + _shape.radius
	_shape.height = _camera.position.y + _shape.radius * 2.0


func _try_grab(tracker_hand: XRPositionalTracker.TrackerHand) -> void:
	var controller := _left_controller if tracker_hand == \
			XRPositionalTracker.TRACKER_HAND_LEFT else _right_controller
	var hand := _left_hand if tracker_hand == \
			XRPositionalTracker.TRACKER_HAND_LEFT else _right_hand
	var result: GrabResult = controller.try_grab(0.2)
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


func _update_turning_input(value: float) -> void:
	if not smooth_turning and not _turn_require_press:
		if not _turning:
			_turning = not is_zero_approx(value)
			if _turning:
				snap_turn(PI / 4.0 if value > 0.0 else -PI / 4.0)
		else:
			_turning = not is_zero_approx(value)
	_turning_input = value


func _on_teleport_left_action_pressed() -> void:
	if can_move and teleporting_enabled:
		_right_teleporter.cancel()
		_left_teleporter.press()


func _on_teleport_left_action_released() -> void:
	_left_teleporter.release()


func _on_teleport_right_action_pressed() -> void:
	if can_move:
		_left_teleporter.cancel()
		_right_teleporter.press()


func _on_teleport_right_action_released() -> void:
	_right_teleporter.release()


func _on_teleporter_teleported(global_position: Vector3) -> void:
	if can_move:
		position_feet(global_position)


func _on_grab_left_action_pressed() -> void:
	_try_grab.call_deferred(XRPositionalTracker.TRACKER_HAND_LEFT)
	_left_glove.grip()


func _on_grab_left_action_released() -> void:
	if is_instance_valid(_left_grabbable):
		_left_grabbable.release(_left_hand.velocity * impulse_multiplier)
	_left_grabbable = null
	_left_glove.release()


func _on_grab_right_action_pressed() -> void:
	_try_grab.call_deferred(XRPositionalTracker.TRACKER_HAND_RIGHT)
	_right_glove.grip()


func _on_grab_right_action_released() -> void:
	if is_instance_valid(_right_grabbable):
		_right_grabbable.release(_right_hand.velocity * impulse_multiplier)
	_right_grabbable = null
	_right_glove.release()


func _on_bounds_check_body_entered(_body: Node) -> void:
	_out_of_bounds_player.play(&"out_of_bounds")


func _on_bounds_check_body_exited(_body: Node) -> void:
	_out_of_bounds_player.play(&"RESET")


func _on_out_of_bounds_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"out_of_bounds":
		bounds_escaped.emit()


func _on_controller_button_pressed(
	name: StringName,
	hand: XRPositionalTracker.TrackerHand
) -> void:
	if name == &"grab":
		if hand == XRPositionalTracker.TRACKER_HAND_LEFT:
			_on_grab_left_action_pressed()
		else:
			assert(hand == XRPositionalTracker.TRACKER_HAND_RIGHT)
			_on_grab_right_action_pressed()
	elif name == &"teleport":
		if hand == XRPositionalTracker.TRACKER_HAND_LEFT:
			_on_teleport_left_action_pressed()
		else:
			assert(hand == XRPositionalTracker.TRACKER_HAND_RIGHT)
			_on_teleport_right_action_pressed()
	elif name == &"walk" and _walk_require_press:
		_walking = continuous_locomotion_enabled
		if _walking:
			_update_locomotion_direction()
	elif name == &"turn" and _turn_require_press:
		if not smooth_turning and not _turning and not is_zero_approx(_turning_input):
			snap_turn(PI / 4.0 if _turning_input > 0.0 else -PI / 4.0)
		_turning = true


func _on_controller_button_released(
	name: StringName,
	hand: XRPositionalTracker.TrackerHand
) -> void:
	if name == &"grab":
		if hand == XRPositionalTracker.TRACKER_HAND_LEFT:
			_on_grab_left_action_released()
		else:
			assert(hand == XRPositionalTracker.TRACKER_HAND_RIGHT)
			_on_grab_right_action_released()
	elif name == &"teleport":
		if hand == XRPositionalTracker.TRACKER_HAND_LEFT:
			_on_teleport_left_action_released()
		else:
			assert(hand == XRPositionalTracker.TRACKER_HAND_RIGHT)
			_on_teleport_right_action_released()
	elif name == &"walk":
		_walking = false
	elif name == &"turn" and _turn_require_press:
		_turning = false


func _on_controller_input_float_changed(
	name: String,
	value: float,
	_hand: XRPositionalTracker.TrackerHand
) -> void:
	if name == &"turn_left":
		_update_turning_input(-value)
	elif name == &"turn_right":
		_update_turning_input(value)


func _on_controller_input_vector2_changed(
	name: StringName,
	value: Vector2,
	_hand: XRPositionalTracker.TrackerHand
) -> void:
	if name == &"walk_direction":
		if not _walk_require_press and _walking_input.is_zero_approx():
			_update_locomotion_direction()
		_walking_input.x = value.x
		_walking_input.y = -value.y
	elif name == &"turn_vector":
		_update_turning_input(value.x)
