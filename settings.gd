extends Node


const SETTINGS_FILE_PATH := "user://settings.cfg"

enum LocomotionDirectionSource { HEAD, LEFT_CONTROLLER, RIGHT_CONTROLLER }
enum LocomotionUpdateMode { ONCE, CONTINUOUS }

var msaa: Viewport.MSAA
var fxaa: bool

var teleporting_enabled: bool
var continuous_locomotion_enabled: bool
var locomotion_direction_source: LocomotionDirectionSource
var locomotion_update_mode: LocomotionUpdateMode

var hand_offset_position: Vector3
var hand_offset_rotation: Vector3


func load_settings(from_path: String = SETTINGS_FILE_PATH) -> int:
	var config_file := ConfigFile.new()
	var error_code := config_file.load(from_path)
	
	Utility.set_framerate(config_file.get_value("performance", "framerate", 90))
	msaa = config_file.get_value("performance", "msaa", SubViewport.MSAA_2X)
	fxaa = config_file.get_value("performance", "fxaa", false)
	teleporting_enabled = config_file.get_value("teleporting", "enabled", true)
	continuous_locomotion_enabled = config_file.get_value("continuous_locomotion", "enabled", false)
	locomotion_direction_source = config_file.get_value("continuous_locomotion", "direction_source", \
			LocomotionDirectionSource.HEAD)
	locomotion_update_mode = config_file.get_value("continuous_locomotion", "update_mode", \
			LocomotionUpdateMode.ONCE)
	hand_offset_position = config_file.get_value("hand_offset", "position", Vector3.ZERO)
	hand_offset_rotation = config_file.get_value("hand_offset", "rotation", Vector3.ZERO)
	
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
	config_file.set_value("hand_offset", "position", hand_offset_position)
	config_file.set_value("hand_offset", "rotation", hand_offset_rotation)
	
	return config_file.save(to_path)


func apply_to_viewport(viewport: Viewport) -> void:
	viewport.msaa_3d = msaa
	viewport.screen_space_aa = \
			Viewport.SCREEN_SPACE_AA_FXAA if fxaa else Viewport.SCREEN_SPACE_AA_DISABLED


func apply_to_player(player: VRPlayer) -> void:
	player.teleporting_enabled = self.teleporting_enabled
	player.continuous_locomotion_enabled = self.continuous_locomotion_enabled
	player.locomotion_direction_source = self.locomotion_direction_source
	player.locomotion_update_mode = self.locomotion_update_mode
	player.set_hand_offset(self.hand_offset_position, self.hand_offset_rotation)
