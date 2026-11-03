extends SceneTree

const FRAMES_TO_RUN: int = 3

var processed_frames: int = 0


func _initialize() -> void:
	var packed_scene: PackedScene = load(
		"res://scenes/main.tscn"
	) as PackedScene

	if packed_scene == null:
		push_error("Unable to load the main scene")
		quit(1)
		return

	var scene_instance: Node = packed_scene.instantiate()
	root.add_child(scene_instance)


func _process(_delta: float) -> bool:
	processed_frames += 1

	if processed_frames >= FRAMES_TO_RUN:
		quit(0)

	return false

