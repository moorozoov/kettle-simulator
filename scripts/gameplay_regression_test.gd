extends SceneTree

var failures: int = 0

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn") as PackedScene
	_check(packed != null, "main scene loads")
	if packed == null:
		_finish()
		return
	var scene: Node = packed.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	var camera: Camera3D = scene.get_node("PlayerCamera") as Camera3D
	var hold: Marker3D = camera.get_node("HoldPoint") as Marker3D
	var kettle_root: Node3D = scene.get_node("Kettle") as Node3D
	var kettle: StaticBody3D = kettle_root.get_node("KettleInteraction") as StaticBody3D
	var collision: CollisionShape3D = kettle.get_node("CollisionShape3D") as CollisionShape3D
	var burner: StaticBody3D = scene.get_node("Burner/BurnerInteraction") as StaticBody3D
	var sink: StaticBody3D = scene.get_node("Sink/SinkInteraction") as StaticBody3D
	var counter: StaticBody3D = scene.get_node("CounterPlacement") as StaticBody3D
	var steam: GPUParticles3D = kettle_root.get_node("SteamParticles") as GPUParticles3D
	var whistle: AudioStreamPlayer3D = kettle_root.get_node("WhistlePlayer") as AudioStreamPlayer3D
	_check_whistle_structure(kettle_root, whistle)

	var stations: Array[StaticBody3D] = [counter, sink, burner]
	kettle.set("water_liters", 1.0)
	kettle.set("temperature", 100.0)
	for cycle: int in range(10):
		camera.call("pick_up_kettle", kettle)
		_check(kettle.get("is_held") as bool, "hot pickup %d" % (cycle + 1))
		_check(collision.disabled, "pickup disables collision %d" % (cycle + 1))
		_check(kettle_root.get_parent() == hold, "pickup parent %d" % (cycle + 1))
		_check((kettle.get("temperature") as float) >= 98.0, "kettle stays hot %d" % (cycle + 1))
		var station: StaticBody3D = stations[cycle % stations.size()]
		var target: Transform3D = station.call("get_kettle_placement_transform")
		camera.set("current_interactable", station)
		camera.call("_try_place_kettle")
		_check(not (kettle.get("is_held") as bool), "hot placement %d" % (cycle + 1))
		_check(kettle.get("current_station") == station, "station state %d" % (cycle + 1))
		_check(not collision.disabled, "placement collision %d" % (cycle + 1))
		_check(kettle_root.get_parent() == scene, "placement parent %d" % (cycle + 1))
		_check(kettle_root.global_transform.is_equal_approx(target), "placement transform %d" % (cycle + 1))

	# Rejected destinations keep the kettle held; a later valid target recovers.
	camera.call("pick_up_kettle", kettle)
	camera.set("current_interactable", null)
	camera.call("_try_place_kettle")
	_check(kettle.get("is_held") as bool, "null target keeps kettle held")
	camera.set("current_interactable", scene.get_node("Counter"))
	camera.call("_try_place_kettle")
	_check(kettle.get("is_held") as bool, "invalid target keeps kettle held")
	counter.set("placed_kettle", sink)
	camera.set("current_interactable", counter)
	camera.call("_try_place_kettle")
	_check(kettle.get("is_held") as bool, "occupied target keeps kettle held")
	counter.set("placed_kettle", null)
	camera.call("_try_place_kettle")
	_check(not (kettle.get("is_held") as bool), "placement recovers after rejected targets")
	_check(kettle.get("current_station") == counter, "recovery registers station")

	# Validate every burner and boiling-feedback transition.
	camera.call("pick_up_kettle", kettle)
	camera.set("current_interactable", burner)
	camera.call("_try_place_kettle")
	kettle.set("water_liters", 1.0)
	kettle.set("temperature", 99.0)
	for toggle: int in range(10):
		burner.call("interact", camera)
		kettle.call("_update_visuals")
		var expected: bool = toggle % 2 == 0
		_check((burner.get("is_turned_on") as bool) == expected, "burner transition %d" % (toggle + 1))
		_check((kettle.call("_should_emit_boiling_feedback") as bool) == expected, "predicate transition %d" % (toggle + 1))
		_check(steam.emitting == expected, "steam transition %d" % (toggle + 1))
		_check(whistle.playing == expected, "audio transition %d" % (toggle + 1))

	# Empty and burned kettles never whistle on an active burner.
	burner.call("interact", camera)
	kettle.set("water_liters", 0.0)
	kettle.call("_update_visuals")
	_check(not (kettle.call("_should_emit_boiling_feedback") as bool), "empty predicate is false")
	_check(not whistle.playing and not steam.emitting, "empty feedback is off")
	kettle.set("water_liters", 1.0)
	kettle.set("is_burned", true)
	kettle.call("_update_visuals")
	_check(not (kettle.call("_should_emit_boiling_feedback") as bool), "burned predicate is false")
	_check(not whistle.playing and not steam.emitting, "burned feedback is off")

	# Pickup from an active sounding burner stops both outputs.
	kettle.set("is_burned", false)
	kettle.call("_update_visuals")
	_check(whistle.playing, "valid boiling state starts before pickup")
	kettle.call("pick_up", hold)
	kettle.call("_update_visuals")
	_check(not whistle.playing and not steam.emitting, "pickup stops boiling feedback")
	scene.queue_free()
	await process_frame
	_finish()

func _check_whistle_structure(root_node: Node3D, player: AudioStreamPlayer3D) -> void:
	for node_name: String in ["WhistleCap", "WhistleOpening", "WhistleLever"]:
		var part: MeshInstance3D = root_node.get_node_or_null(node_name) as MeshInstance3D
		_check(part != null and part.mesh != null, "%s is a physical mesh" % node_name)
		if part != null:
			_check(
				part.position.x > 0.35 and part.position.y > 0.35,
				"%s is positioned at the spout tip" % node_name
			)
	var cap: MeshInstance3D = root_node.get_node("WhistleCap") as MeshInstance3D
	_check(cap.position.x > 0.35 and cap.position.y > 0.35, "whistle is on spout tip")
	var players: Array[Node] = root_node.find_children("*", "AudioStreamPlayer3D", true, false)
	_check(players.size() == 1, "exactly one 3D audio player")
	_check(player.stream != null, "whistle audio stream is assigned")
	var ogg_stream: AudioStreamOggVorbis = player.stream as AudioStreamOggVorbis
	_check(ogg_stream != null and ogg_stream.loop, "whistle OGG stream loops")
	_check(is_equal_approx(player.volume_db, -20.0), "whistle is -20 dB")
	_check(is_equal_approx(player.max_distance, 5.0), "whistle max distance is 5 m")

func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
		return
	failures += 1
	push_error("FAIL: %s" % description)

func _finish() -> void:
	if failures == 0:
		print("Gameplay regression test passed.")
		quit(0)
	else:
		push_error("Gameplay regression test failed: %d checks" % failures)
		quit(1)
