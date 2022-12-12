extends Node3D


@onready var player := $VRPlayer as VRPlayer
@onready var player_start_position := player.position


func _ready():
	Settings.load_settings()
	var viewport := get_viewport()
	Utility.initialize_openxr(viewport)
	Settings.apply_to_viewport(viewport)
	Settings.apply_to_player(player)
	$RotatingDoor.add_collision_exception_with($Doorframe)


func _exit_tree():
	Settings.save_settings()


func _on_vr_player_bounds_escaped():
	player.position_feet(player_start_position)
