extends Node


## Default file path to load settings from.
const SETTINGS_FILE_PATH = "user://settings.cfg"
## Default file path to load controller settings from.
const CONTROLLER_SETTINGS_PATH = "user://controller_settings.cfg"
const _DEFAULT_CONTROLLER_SETTINGS = {
	"/interaction_profiles/htc/vive_controller" = "res://controller_defaults/vive_controller.tres",
	"/interaction_profiles/oculus/touch_controller" = "res://controller_defaults/touch_controller.tres",
	"/interaction_profiles/valve/index_controller" = "res://controller_defaults/index_controller.tres",
}

## Sources to use for the player's walking direction.
enum LocomotionDirectionSource {
	HEAD, ## The direction the player walks is based on the orientation of their headset.
	LEFT_CONTROLLER, ## The direction the player walks is based on the orientation of their left controller.
	RIGHT_CONTROLLER, ## The direction the player walks is based on the orientation of their right controller.
}
## How the direction the player walks updates.
enum LocomotionUpdateMode {
	ONCE, ## Turning does not affect the player's movement direction while they are walking.
	CONTINUOUS, ## Turning affects the player's movement direction continuously.
}

## The level of multisample anti-aliasing to use.
var msaa: Viewport.MSAA
## If [code]true[/code], use fast approximate anti-aliasing.
var fxaa: bool

## If [code]true[/code], the player can move by teleporting.
var teleporting_enabled: bool
## If [code]true[/code], the player can move by walking.
var continuous_locomotion_enabled: bool
## The source to use for the player's walking direction. See [enum LocomotionDirectionSource].
var locomotion_direction_source: LocomotionDirectionSource
## How to update the player's walking direction. See [enum LocomotionUpdateMode].
var locomotion_update_mode: LocomotionUpdateMode
## If [code]true[/code], the player turns smoothly every frame instead of snap turning in increments.
var smooth_turning: bool

var _controller_settings: ConfigFile


## Load settings from the file at [param from_path]. Returns the error code from reading the file.
func load_settings(from_path: String = SETTINGS_FILE_PATH) -> int:
	var config_file := ConfigFile.new()
	var error_code := config_file.load(from_path)
	
	Utility.set_framerate(config_file.get_value("performance", "framerate", 90))
	msaa = config_file.get_value("performance", "msaa", Viewport.MSAA_2X)
	fxaa = config_file.get_value("performance", "fxaa", false)
	teleporting_enabled = config_file.get_value("teleporting", "enabled", true)
	continuous_locomotion_enabled = config_file.get_value("continuous_locomotion", "enabled", false)
	locomotion_direction_source = config_file.get_value(
		"continuous_locomotion",
		"direction_source",
		LocomotionDirectionSource.HEAD
	)
	locomotion_update_mode = config_file.get_value(
		"continuous_locomotion",
		"update_mode",
		LocomotionUpdateMode.ONCE
	)
	smooth_turning = config_file.get_value("turning", "smooth_turning", false)
	
	return error_code


## Save settings at the location [param to_path]. Returns the error code from saving the file.
func save_settings(to_path: String = SETTINGS_FILE_PATH) -> int:
	var config_file := ConfigFile.new()
	
	config_file.set_value("performance", "framerate", Engine.physics_ticks_per_second)
	config_file.set_value("performance", "msaa", msaa)
	config_file.set_value("performance", "fxaa", fxaa)
	config_file.set_value("teleporting", "enabled", teleporting_enabled)
	config_file.set_value("continuous_locomotion", "enabled", continuous_locomotion_enabled)
	config_file.set_value("continuous_locomotion", "direction_source", locomotion_direction_source)
	config_file.set_value("continuous_locomotion", "update_mode", locomotion_update_mode)
	config_file.set_value("turning", "smooth_turning", smooth_turning)
	
	return config_file.save(to_path)


## Load settings for the controller with the given [param controller_name], from the file at
## [param from_path].
func get_controller_settings(
	controller_name: String,
	from_path := CONTROLLER_SETTINGS_PATH
) -> ControllerSettings:
	var output := load(
		_DEFAULT_CONTROLLER_SETTINGS.get(controller_name, "res://controller_defaults/default.tres")
	) as ControllerSettings
	if not is_instance_valid(_controller_settings):
		_controller_settings = ConfigFile.new()
		_controller_settings.load(from_path)
	
	if _controller_settings.has_section(controller_name):
		output.hand_offset_position = _controller_settings.get_value(
			controller_name,
			"hand_offset_position",
			output.hand_offset_position
		)
		output.hand_offset_rotation = _controller_settings.get_value(
			controller_name,
			"hand_offset_rotation",
			output.hand_offset_rotation
		)
		output.walk_require_press = _controller_settings.get_value(
			controller_name,
			"walk_require_press",
			output.walk_require_press
		)
		output.turn_require_press = _controller_settings.get_value(
			controller_name,
			"turn_require_press",
			output.turn_require_press
		)
		output.pose = _controller_settings.get_value(controller_name, "pose", output.pose)
	else:
		_controller_settings.set_value(
			controller_name,
			"hand_offset_position",
			output.hand_offset_position
		)
		_controller_settings.set_value(
			controller_name,
			"hand_offset_rotation",
			output.hand_offset_rotation
		)
		_controller_settings.set_value(
			controller_name,
			"walk_require_press",
			output.walk_require_press
		)
		_controller_settings.set_value(
			controller_name,
			"turn_require_press",
			output.turn_require_press
		)
		_controller_settings.set_value(controller_name, "pose", output.pose)
	
	return output


## Save controller settings at the location [param to_path]. Returns the error code from saving the
## file.
func save_controller_settings(to_path := CONTROLLER_SETTINGS_PATH) -> int:
	if is_instance_valid(_controller_settings):
		return _controller_settings.save(to_path)
	else:
		return -1


## Apply these settings to the given [param viewport].
func apply_to_viewport(viewport: Viewport) -> void:
	viewport.msaa_3d = msaa
	viewport.screen_space_aa = \
			Viewport.SCREEN_SPACE_AA_FXAA if fxaa else Viewport.SCREEN_SPACE_AA_DISABLED


## Apply these settings to the given [param player].
func apply_to_player(player: VRPlayer) -> void:
	player.teleporting_enabled = self.teleporting_enabled
	player.continuous_locomotion_enabled = self.continuous_locomotion_enabled
	player.locomotion_direction_source = self.locomotion_direction_source
	player.locomotion_update_mode = self.locomotion_update_mode
	player.smooth_turning = self.smooth_turning
