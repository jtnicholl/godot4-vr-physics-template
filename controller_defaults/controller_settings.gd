## Provides default settings for a VR controller.
class_name ControllerSettings extends Resource


## Offset the player's hands by this distance.[br]
## The offset is relative to the right hand, the value will be flipped for the
## left hand.
@export var hand_offset_position: Vector3
## Offset the player's hands by this rotation, as an YXZ Euler angle.[br]
## The offset is relative to the right hand, the value will be flipped for the
## left hand.
@export var hand_offset_rotation: Vector3
## If [code]true[/code], require pressing the boolean [code]walk[/code] action to walk, in addition
## to a directional input. Useful for trackpads but not sticks, for example.
@export var walk_require_press: bool
## If [code]true[/code], require pressing the boolean [code]turn[/code] action to turn, in addition
## to a directional input. Useful for trackpads but not sticks, for example.
@export var turn_require_press: bool
## The OpenXR pose action to use for the position of the player's hands.
@export var pose := &"default"
