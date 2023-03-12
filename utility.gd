class_name Utility


## Prepare OpenXR to use the given [param viewport].[br]
## Returns [code]true[/code] if OpenXR initialized successfully.
static func initialize_openxr(viewport: Viewport) -> bool:
	var vr_interface := XRServer.find_interface(&"OpenXR")
	if is_instance_valid(vr_interface) and vr_interface.initialize():
		viewport.size = vr_interface.get_render_target_size()
		viewport.use_xr = true
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		return true
	else:
		return false


## Set both the physics framerate and the maximum process/render framerate.
static func set_framerate(framerate: int) -> void:
	Engine.physics_ticks_per_second = framerate
	Engine.max_fps = framerate
