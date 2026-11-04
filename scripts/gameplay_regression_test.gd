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
	_check_counter_placement(counter)
	_check_sink_geometry(scene)

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
	_check(
		(kettle.call("_get_state_text") as String).contains("остывает"),
		"hot kettle on counter reports cooling"
	)
	camera.call("pick_up_kettle", kettle)
	camera.set("current_interactable", sink)
	camera.call("_try_place_kettle")
	_check(
		(kettle.call("_get_state_text") as String).contains("остывает"),
		"hot kettle in sink reports cooling"
	)

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
	kettle.set("temperature", 50.0)
	burner.call("interact", camera)
	_check(
		(kettle.call("_get_state_text") as String).contains("нагревается"),
		"active burner reports heating"
	)
	burner.call("interact", camera)
	kettle.set("temperature", 20.0)
	_check(
		(kettle.call("_get_state_text") as String).contains("холодный"),
		"room-temperature kettle remains cold"
	)
	kettle.set("temperature", 99.0)
	for toggle: int in range(10):
		burner.call("interact", camera)
		kettle.call("_update_visuals")
		var expected: bool = toggle % 2 == 0
		_check((burner.get("is_turned_on") as bool) == expected, "burner transition %d" % (toggle + 1))
		_check((kettle.call("_should_emit_boiling_feedback") as bool) == expected, "predicate transition %d" % (toggle + 1))
		_check(steam.emitting == expected, "steam transition %d" % (toggle + 1))
		_check(whistle.playing == expected, "audio transition %d" % (toggle + 1))
	_check(
		(kettle.call("_get_state_text") as String).contains("остывает"),
		"turned-off burner changes near-boiling state to cooling"
	)

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
	_check(
		(kettle.call("_get_state_text") as String).contains("сгорел"),
		"burned state keeps priority over cooling"
	)

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
	var spout: MeshInstance3D = root_node.get_node("Spout") as MeshInstance3D
	var spout_mesh: CylinderMesh = spout.mesh as CylinderMesh
	for node_name: String in ["WhistleCap", "WhistleOpening", "WhistleLever"]:
		var part: MeshInstance3D = root_node.find_child(
			node_name,
			true,
			false
		) as MeshInstance3D
		_check(part != null and part.mesh != null, "%s is a physical mesh" % node_name)
		if part != null:
			_check(
				part.get_parent().name == "Spout",
				"%s is attached to the spout" % node_name
			)
	var cap: MeshInstance3D = spout.get_node("WhistleCap") as MeshInstance3D
	var cap_mesh: CylinderMesh = cap.mesh as CylinderMesh
	var opening: MeshInstance3D = spout.get_node("WhistleOpening") as MeshInstance3D
	var lever: MeshInstance3D = spout.get_node("WhistleLever") as MeshInstance3D
	var spout_outward_tip: float = -spout_mesh.height * 0.5
	var cap_inner_edge: float = cap.position.y + cap_mesh.height * 0.5
	var cap_outer_edge: float = cap.position.y - cap_mesh.height * 0.5
	_check(cap.position.y < spout_outward_tip, "whistle cap is beyond outward spout tip")
	_check(cap_inner_edge >= spout_outward_tip - 0.01, "whistle cap overlaps spout end")
	_check(
		absf(cap.transform.basis.y.normalized().dot(Vector3.UP)) > 0.999,
		"whistle cap axis matches spout axis"
	)
	_check(
		opening.position.y >= cap_outer_edge - 0.02
		and opening.position.y <= cap.position.y,
		"whistle opening closes the cap outlet"
	)
	_check(
		lever.position.y >= cap_outer_edge
		and lever.position.y <= cap_inner_edge,
		"whistle lever remains attached to cap"
	)
	_check(
		cap.global_position.distance_to(root_node.global_position)
		> spout.global_position.distance_to(root_node.global_position),
		"whistle is farther outward than spout center"
	)
	var players: Array[Node] = root_node.find_children("*", "AudioStreamPlayer3D", true, false)
	_check(players.size() == 1, "exactly one 3D audio player")
	_check(player.stream != null, "whistle audio stream is assigned")
	var ogg_stream: AudioStreamOggVorbis = player.stream as AudioStreamOggVorbis
	_check(ogg_stream != null and ogg_stream.loop, "whistle OGG stream loops")
	_check(is_equal_approx(player.volume_db, -20.0), "whistle is -20 dB")
	_check(is_equal_approx(player.max_distance, 5.0), "whistle max distance is 5 m")

func _check_counter_placement(counter: StaticBody3D) -> void:
	var marker: Marker3D = counter.get_node("KettlePoint") as Marker3D
	var collision: CollisionShape3D = counter.get_node("CollisionShape3D") as CollisionShape3D
	var shape: BoxShape3D = collision.shape as BoxShape3D
	var target: Vector3 = marker.global_position
	_check(target.x >= 0.55 and target.x <= 1.35, "counter target is on free right side")
	_check(target.z >= -0.1 and target.z <= 0.11, "counter target stays on countertop depth")
	_check(absf(target.z) + 0.25 <= 0.351, "kettle footprint stays on countertop")
	_check(is_equal_approx(target.y + 0.02, 0.9), "kettle base touches top surface")
	_check(shape != null and shape.size.z <= 0.3, "counter ray zone covers front surface only")

func _check_sink_geometry(scene: Node) -> void:
	var sink: MeshInstance3D = scene.get_node("Sink") as MeshInstance3D
	var bottom: MeshInstance3D = sink.get_node("BasinInterior") as MeshInstance3D
	var bottom_mesh: BoxMesh = bottom.mesh as BoxMesh
	_check(sink.mesh == null, "sink has no solid flat cover mesh")
	_check(bottom_mesh != null, "sink has a physical recessed bottom")
	var bottom_top: float = bottom.global_position.y + bottom_mesh.size.y * 0.5
	_check(
		bottom_top < sink.global_position.y - 0.1,
		"sink bottom is recessed below counter top"
	)

	for wall_name: String in [
		"BasinWallFront",
		"BasinWallBack",
		"BasinWallLeft",
		"BasinWallRight"
	]:
		var wall: MeshInstance3D = sink.get_node_or_null(wall_name) as MeshInstance3D
		_check(wall != null and wall.mesh != null, "%s closes basin" % wall_name)

	for rim_name: String in ["RimFront", "RimBack", "RimLeft", "RimRight"]:
		var rim: MeshInstance3D = sink.get_node_or_null(rim_name) as MeshInstance3D
		_check(rim != null and rim.mesh != null, "%s frames basin opening" % rim_name)

	var nozzle: MeshInstance3D = sink.get_node("FaucetNozzle") as MeshInstance3D
	var stream: MeshInstance3D = sink.get_node("WaterStream") as MeshInstance3D
	var nozzle_mesh: CylinderMesh = nozzle.mesh as CylinderMesh
	var stream_mesh: CylinderMesh = stream.mesh as CylinderMesh
	_check(
		nozzle.position.is_equal_approx(Vector3(0.0, 0.64, 0.0)),
		"faucet nozzle keeps approved alignment"
	)
	_check(
		stream.position.is_equal_approx(Vector3(0.0, 0.375, 0.0)),
		"water stream keeps approved alignment"
	)
	_check(
		is_equal_approx(nozzle.global_position.x, stream.global_position.x)
		and is_equal_approx(nozzle.global_position.z, stream.global_position.z),
		"faucet stream remains centered below nozzle"
	)
	var nozzle_bottom: float = nozzle.global_position.y - nozzle_mesh.height * 0.5
	var stream_top: float = stream.global_position.y + stream_mesh.height * 0.5
	_check(is_equal_approx(nozzle_bottom, stream_top), "stream starts at nozzle outlet")
	_check(
		stream.global_transform.basis.y.normalized().dot(Vector3.UP) > 0.999,
		"faucet stream remains vertical"
	)

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
