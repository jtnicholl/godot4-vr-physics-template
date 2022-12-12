class_name Utility


static func initialize_openxr(viewport: Viewport) -> bool:
	var vr_interface := XRServer.find_interface(&"OpenXR")
	if is_instance_valid(vr_interface) and vr_interface.initialize():
		viewport.size = vr_interface.get_render_target_size()
		viewport.use_xr = true
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		return true
	else:
		return false


static func set_framerate(framerate: int) -> void:
	Engine.physics_ticks_per_second = framerate
	Engine.max_fps = framerate
