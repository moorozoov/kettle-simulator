extends SceneTree

var failures: int = 0
var packed_scene: PackedScene
var terminal_emissions: int = 0
var initial_camera_transform: Transform3D
var initial_kettle_transform: Transform3D


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	packed_scene = load("res://scenes/main.tscn") as PackedScene
	_check(packed_scene != null, "main scene loads for session regression")
	if packed_scene == null:
		_finish()
		return

	await _check_false_success_boundaries()
	await _check_success_by_burner_off()
	await _check_success_by_pickup()
	await _check_evaporated_kettle_does_not_succeed()
	await _check_failure_precedence()
	await _check_flood_is_non_terminal()
	await _check_five_clean_scene_resets()
	_finish()


func _instantiate_scene() -> Node:
	var scene: Node = packed_scene.instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	return scene


func _prepare_heating(scene: Node, temperature: float, water_liters: float = 1.0) -> Dictionary:
	var controller: SessionController = scene.get_node("SessionController") as SessionController
	var kettle: StaticBody3D = scene.get_node("Kettle/KettleInteraction") as StaticBody3D
	var burner: StaticBody3D = scene.get_node("Burner/BurnerInteraction") as StaticBody3D
	kettle.set("water_liters", water_liters)
	kettle.set("temperature", temperature)
	if not (burner.get("is_turned_on") as bool):
		burner.call("interact", null)
	controller.call("_evaluate_session")
	return {
		"controller": controller,
		"kettle": kettle,
		"burner": burner,
	}


func _check_false_success_boundaries() -> void:
	for temperature: float in [99.0, 99.99]:
		var scene: Node = await _instantiate_scene()
		var nodes: Dictionary = _prepare_heating(scene, temperature)
		var controller: SessionController = nodes["controller"] as SessionController
		var burner: StaticBody3D = nodes["burner"] as StaticBody3D
		burner.call("interact", null)
		controller.call("_evaluate_session")
		_check(
			controller.state == SessionController.SessionState.RUNNING,
			"%.2f C then burner off does not succeed" % temperature
		)
		scene.queue_free()
		await process_frame


func _check_success_by_burner_off() -> void:
	var scene: Node = await _instantiate_scene()
	var nodes: Dictionary = _prepare_heating(scene, 100.0)
	var controller: SessionController = nodes["controller"] as SessionController
	var burner: StaticBody3D = nodes["burner"] as StaticBody3D
	_check(controller.state == SessionController.SessionState.RUNNING, "boiling alone stays running")
	_check(controller.has_reached_boiling, "real boiling is latched")
	burner.call("interact", null)
	controller.call("_evaluate_session")
	_check(controller.state == SessionController.SessionState.SUCCESS, "burner off after boil succeeds")
	_check(scene.get_node("UI/ResultOverlay").visible, "success result is visible")
	scene.queue_free()
	await process_frame


func _check_success_by_pickup() -> void:
	var scene: Node = await _instantiate_scene()
	var nodes: Dictionary = _prepare_heating(scene, 100.0)
	var controller: SessionController = nodes["controller"] as SessionController
	var kettle: StaticBody3D = nodes["kettle"] as StaticBody3D
	var hold: Marker3D = scene.get_node("PlayerCamera/HoldPoint") as Marker3D
	kettle.call("pick_up", hold)
	controller.call("_evaluate_session")
	_check(controller.state == SessionController.SessionState.SUCCESS, "pickup after boil succeeds")
	scene.queue_free()
	await process_frame


func _check_evaporated_kettle_does_not_succeed() -> void:
	var scene: Node = await _instantiate_scene()
	var nodes: Dictionary = _prepare_heating(scene, 100.0)
	var controller: SessionController = nodes["controller"] as SessionController
	var kettle: StaticBody3D = nodes["kettle"] as StaticBody3D
	var burner: StaticBody3D = nodes["burner"] as StaticBody3D
	kettle.set("water_liters", 0.0)
	burner.call("interact", null)
	controller.call("_evaluate_session")
	_check(
		controller.state == SessionController.SessionState.RUNNING,
		"fully evaporated kettle cannot succeed"
	)
	scene.queue_free()
	await process_frame


func _check_failure_precedence() -> void:
	var scene: Node = await _instantiate_scene()
	var nodes: Dictionary = _prepare_heating(scene, 100.0)
	var controller: SessionController = nodes["controller"] as SessionController
	var kettle: StaticBody3D = nodes["kettle"] as StaticBody3D
	var burner: StaticBody3D = nodes["burner"] as StaticBody3D
	kettle.set("water_liters", 0.0)
	kettle.set("temperature", kettle.get("burn_temperature") as float)
	kettle.set("is_burned", true)
	burner.call("interact", null)
	controller.call("_evaluate_session")
	_check(controller.state == SessionController.SessionState.FAILURE, "burning wins over success")
	_check(
		(scene.get_node("UI/ResultOverlay/Panel/Content/ResultLabel") as Label).text.contains("Провал"),
		"failure result is understandable"
	)
	scene.queue_free()
	await process_frame


func _check_flood_is_non_terminal() -> void:
	var scene: Node = await _instantiate_scene()
	var controller: SessionController = scene.get_node("SessionController") as SessionController
	var sink: StaticBody3D = scene.get_node("Sink/SinkInteraction") as StaticBody3D
	for amount: float in [11.99, 12.0, 12.01]:
		sink.set("unattended_spilled_water", amount)
		sink.call("_update_spill_visuals")
		controller.call("_evaluate_session")
		_check(
			controller.state == SessionController.SessionState.RUNNING,
			"flood %.2f L is non-terminal" % amount
		)
	scene.queue_free()
	await process_frame


func _check_five_clean_scene_resets() -> void:
	var first_scene: Node = await _instantiate_current_scene()
	initial_camera_transform = (first_scene.get_node("PlayerCamera") as Camera3D).transform
	initial_kettle_transform = (first_scene.get_node("Kettle") as Node3D).transform
	_check_reset_state(first_scene, 0)

	for cycle: int in range(5):
		var scene: Node = current_scene
		var old_scene_id: int = scene.get_instance_id()
		var old_interactable_id: int = (
			scene.get_node("Sink/SinkInteraction") as StaticBody3D
		).get_instance_id()
		var controller: SessionController = scene.get_node("SessionController") as SessionController
		terminal_emissions = 0
		controller.state_changed.connect(_on_session_state_changed)
		_pollute_scene_before_restart(scene, cycle)
		_reach_terminal_state(scene, cycle)
		_check(
			controller.state != SessionController.SessionState.RUNNING,
			"restart %d starts from a terminal state" % (cycle + 1)
		)
		_check(terminal_emissions == 1, "restart %d emits one terminal transition" % (cycle + 1))
		controller.call("_evaluate_session")
		_check(terminal_emissions == 1, "restart %d terminal transition is not duplicated" % (cycle + 1))

		controller.request_restart()
		controller.request_restart()
		_check(controller.restart_pending, "restart %d duplicate request is guarded" % (cycle + 1))
		await process_frame
		await process_frame
		_check(current_scene != null, "restart %d creates a current scene" % (cycle + 1))
		if current_scene == null:
			return
		_check(
			current_scene.get_instance_id() != old_scene_id,
			"restart %d replaces the old scene" % (cycle + 1)
		)
		_check_reset_state(current_scene, cycle + 1, old_interactable_id)

	current_scene.queue_free()
	await process_frame
	current_scene = null


func _instantiate_current_scene() -> Node:
	var scene: Node = packed_scene.instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	await process_frame
	return scene


func _pollute_scene_before_restart(scene: Node, cycle: int) -> void:
	var kettle: StaticBody3D = scene.get_node("Kettle/KettleInteraction") as StaticBody3D
	var sink: StaticBody3D = scene.get_node("Sink/SinkInteraction") as StaticBody3D
	var camera: Camera3D = scene.get_node("PlayerCamera") as Camera3D
	kettle.set("overflow_timer", 0.2)
	kettle.set("total_spilled_water", 2.0 + cycle)
	(scene.get_node("Kettle/SteamParticles") as GPUParticles3D).emitting = true
	(scene.get_node("Kettle/SmokeParticles") as GPUParticles3D).emitting = true
	(scene.get_node("Kettle/OverflowLidParticles") as GPUParticles3D).emitting = true
	(scene.get_node("Kettle/OverflowSpoutParticles") as GPUParticles3D).emitting = true
	(scene.get_node("Kettle/WhistlePlayer") as AudioStreamPlayer3D).play()
	if not (sink.get("water_is_on") as bool):
		sink.call("interact", null)
	sink.set("unattended_spilled_water", 13.0 + cycle)
	sink.call("_update_spill_visuals")
	camera.transform.origin += Vector3(0.25, 0.1, -0.2)
	camera.set("current_interactable", sink)


func _reach_terminal_state(scene: Node, cycle: int) -> void:
	var controller: SessionController = scene.get_node("SessionController") as SessionController
	var kettle: StaticBody3D = scene.get_node("Kettle/KettleInteraction") as StaticBody3D
	var burner: StaticBody3D = scene.get_node("Burner/BurnerInteraction") as StaticBody3D
	var camera: Camera3D = scene.get_node("PlayerCamera") as Camera3D

	if cycle % 3 == 2:
		kettle.set("water_liters", 0.0)
		kettle.set("temperature", kettle.get("burn_temperature") as float)
		kettle.set("is_burned", true)
		controller.call("_evaluate_session")
		return

	kettle.set("water_liters", 1.0)
	kettle.set("temperature", 100.0)
	if not (burner.get("is_turned_on") as bool):
		burner.call("interact", null)
	controller.call("_evaluate_session")
	if cycle % 3 == 0:
		burner.call("interact", null)
	else:
		camera.call("pick_up_kettle", kettle)
	controller.call("_evaluate_session")


func _check_reset_state(
	scene: Node,
	reset_number: int,
	old_interactable_id: int = 0
) -> void:
	var label: String = "initial state" if reset_number == 0 else "reset %d" % reset_number
	var controllers: Array[Node] = scene.find_children(
		"SessionController",
		"SessionController",
		true,
		false
	)
	var audio_players: Array[Node] = scene.find_children(
		"*",
		"AudioStreamPlayer3D",
		true,
		false
	)
	var controller: SessionController = scene.get_node("SessionController") as SessionController
	var kettle_root: Node3D = scene.get_node("Kettle") as Node3D
	var kettle: StaticBody3D = scene.get_node("Kettle/KettleInteraction") as StaticBody3D
	var collision: CollisionShape3D = kettle.get_node("CollisionShape3D") as CollisionShape3D
	var burner: StaticBody3D = scene.get_node("Burner/BurnerInteraction") as StaticBody3D
	var sink: StaticBody3D = scene.get_node("Sink/SinkInteraction") as StaticBody3D
	var camera: Camera3D = scene.get_node("PlayerCamera") as Camera3D
	_check(controllers.size() == 1, "%s has one controller" % label)
	_check(audio_players.size() == 1, "%s has one audio player" % label)
	_check(controller.state == SessionController.SessionState.RUNNING, "%s is running" % label)
	_check(not controller.has_reached_boiling, "%s clears boil latch" % label)
	_check(not controller.restart_pending, "%s clears restart guard" % label)
	_check(kettle_root.get_parent() == scene, "%s restores kettle parent" % label)
	_check(kettle_root.transform.is_equal_approx(initial_kettle_transform), "%s restores kettle transform" % label)
	_check(kettle.get("current_station") == burner, "%s registers kettle on burner" % label)
	_check(burner.get("placed_kettle") == kettle, "%s restores burner station" % label)
	_check(not (kettle.get("is_held") as bool), "%s releases kettle" % label)
	_check(not collision.disabled, "%s enables kettle collision" % label)
	_check(is_equal_approx(kettle.get("water_liters") as float, 0.0), "%s empties kettle" % label)
	_check(is_equal_approx(kettle.get("temperature") as float, 20.0), "%s restores temperature" % label)
	_check(not (kettle.get("is_burned") as bool), "%s restores kettle" % label)
	_check(is_zero_approx(kettle.get("overflow_timer") as float), "%s clears overflow timer" % label)
	_check(is_zero_approx(kettle.get("total_spilled_water") as float), "%s clears kettle spill" % label)
	_check(not (burner.get("is_turned_on") as bool), "%s turns burner off" % label)
	_check(not (sink.get("water_is_on") as bool), "%s turns faucet off" % label)
	_check(is_zero_approx(sink.get("unattended_spilled_water") as float), "%s clears room spill" % label)
	_check(not (scene.get_node("Sink/WaterStream") as MeshInstance3D).visible, "%s hides water stream" % label)
	_check(not (scene.get_node("Kettle/SteamParticles") as GPUParticles3D).emitting, "%s stops steam" % label)
	_check(not (scene.get_node("Kettle/SmokeParticles") as GPUParticles3D).emitting, "%s stops smoke" % label)
	_check(not (scene.get_node("Kettle/OverflowLidParticles") as GPUParticles3D).emitting, "%s stops lid overflow" % label)
	_check(not (scene.get_node("Kettle/OverflowSpoutParticles") as GPUParticles3D).emitting, "%s stops spout overflow" % label)
	_check(not (scene.get_node("Kettle/WhistlePlayer") as AudioStreamPlayer3D).playing, "%s stops audio" % label)
	_check(not scene.get_node("CounterPuddle").visible, "%s hides counter puddle" % label)
	_check(not scene.get_node("TableDrip").visible, "%s hides table drip" % label)
	_check(not scene.get_node("FloorPuddle").visible, "%s hides floor puddle" % label)
	_check(not scene.get_node("RoomFloodWater").visible, "%s hides flood" % label)
	_check(camera.transform.is_equal_approx(initial_camera_transform), "%s restores camera transform" % label)
	_check(camera.get("held_kettle") == null, "%s clears held reference" % label)
	var current_interactable: Object = camera.get("current_interactable") as Object
	var interaction_is_fresh: bool = current_interactable == null
	if is_instance_valid(current_interactable) and current_interactable is Node:
		var current_node: Node = current_interactable as Node
		interaction_is_fresh = (
			current_node.is_inside_tree()
			and scene.is_ancestor_of(current_node)
			and (
				old_interactable_id == 0
				or current_node.get_instance_id() != old_interactable_id
			)
		)
	_check(interaction_is_fresh, "%s has no stale interaction reference" % label)
	_check(scene.get_node("UI/GoalHint").visible, "%s restores goal" % label)
	_check(not scene.get_node("UI/ResultOverlay").visible, "%s hides result" % label)


func _on_session_state_changed(
	_previous_state: SessionController.SessionState,
	_new_state: SessionController.SessionState
) -> void:
	terminal_emissions += 1


func _check(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
		return
	failed(description)


func failed(description: String) -> void:
	failures += 1
	push_error("FAIL: %s" % description)


func _finish() -> void:
	if failures == 0:
		print("Session regression test passed.")
		quit(0)
	else:
		push_error("Session regression test failed: %d checks" % failures)
		quit(1)
