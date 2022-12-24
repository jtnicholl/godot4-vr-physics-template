extends Node3D


@onready var player := $VRPlayer as VRPlayer
@onready var player_start_position := player.position


func _ready() -> void:
	Settings.load_settings()
	var viewport := get_viewport()
	Utility.initialize_openxr(viewport)
	Settings.apply_to_viewport(viewport)
	Settings.apply_to_player(player)


func _exit_tree() -> void:
	Settings.save_settings()


func _on_vr_player_bounds_escaped() -> void:
	player.position_feet(player_start_position)
