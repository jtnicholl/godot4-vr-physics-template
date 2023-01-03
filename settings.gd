extends Node


const SETTINGS_FILE_PATH := "user://settings.cfg"
const CONTROLLER_SETTINGS_PATH := "user://controller_settings.cfg"
const _DEFAULT_CONTROLLER_SETTINGS := {
	"/interaction_profiles/htc/vive_controller" = "res://controller_defaults/vive_controller.tres",
}

enum LocomotionDirectionSource { HEAD, LEFT_CONTROLLER, RIGHT_CONTROLLER }
enum LocomotionUpdateMode { ONCE, CONTINUOUS }

var msaa: Viewport.MSAA
var fxaa: bool

var teleporting_enabled: bool
var continuous_locomotion_enabled: bool
var locomotion_direction_source: LocomotionDirectionSource
var locomotion_update_mode: LocomotionUpdateMode

var _controller_settings: ConfigFile


func load_settings(from_path: String = SETTINGS_FILE_PATH) -> int:
	var config_file := ConfigFile.new()
	var error_code := config_file.load(from_path)
	
	Utility.set_framerate(config_file.get_value("performance", "framerate", 90))
	msaa = config_file.get_value("performance", "msaa", SubViewport.MSAA_2X)
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
	
	return error_code


func save_settings(to_path: String = SETTINGS_FILE_PATH) -> int:
	var config_file := ConfigFile.new()
	
	config_file.set_value("performance", "framerate", Engine.physics_ticks_per_second)
	config_file.set_value("performance", "msaa", msaa)
	config_file.set_value("performance", "fxaa", fxaa)
	config_file.set_value("teleporting", "enabled", teleporting_enabled)
	config_file.set_value("continuous_locomotion", "enabled", continuous_locomotion_enabled)
	config_file.set_value("continuous_locomotion", "direction_source", locomotion_direction_source)
	config_file.set_value("continuous_locomotion", "update_mode", locomotion_update_mode)
	
	return config_file.save(to_path)


func get_controller_settings(
	controller_name: String,
	from_path := CONTROLLER_SETTINGS_PATH
) -> ControllerSettings:
	var output := load(_DEFAULT_CONTROLLER_SETTINGS[controller_name]) as ControllerSettings
	if not is_instance_valid(output):
		output = ControllerSettings.new()
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
	
	return output


func save_controller_settings(to_path := CONTROLLER_SETTINGS_PATH) -> int:
	if is_instance_valid(_controller_settings):
		return _controller_settings.save(to_path)
	else:
		return -1


func apply_to_viewport(viewport: Viewport) -> void:
	viewport.msaa_3d = msaa
	viewport.screen_space_aa = \
			Viewport.SCREEN_SPACE_AA_FXAA if fxaa else Viewport.SCREEN_SPACE_AA_DISABLED


func apply_to_player(player: VRPlayer) -> void:
	player.teleporting_enabled = self.teleporting_enabled
	player.continuous_locomotion_enabled = self.continuous_locomotion_enabled
	player.locomotion_direction_source = self.locomotion_direction_source
	player.locomotion_update_mode = self.locomotion_update_mode
