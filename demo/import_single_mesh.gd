@tool
extends EditorScenePostImport


func _post_import(scene: Node) -> Object:
	return scene.get_child(0)
