extends Node3D


@onready var player := $VRPlayer as VRPlayer
@onready var player_start_position := player.position


func _ready() -> void:
	Settings.load_settings()
	var viewport := get_viewport()
	Utility.initialize_openxr(viewport)
	XRServer.get_tracker(&"left_hand").profile_changed.connect(_on_controller_profile_changed)
	XRServer.get_tracker(&"right_hand").profile_changed.connect(_on_controller_profile_changed)
	Settings.apply_to_viewport(viewport)
	Settings.apply_to_player(player)


func _input(event: InputEvent) -> void:
	# Temporary workaround for godotengine/godot#70755
	if event.is_action_pressed(&"ui_accept"):
		Settings.save_settings()
		Settings.save_controller_settings()


func _exit_tree() -> void:
	Settings.save_settings()
	Settings.save_controller_settings()


func _on_controller_profile_changed(role: String) -> void:
	player.set_controller_settings(Settings.get_controller_settings(role))


func _on_vr_player_bounds_escaped() -> void:
	player.position_feet(player_start_position)
