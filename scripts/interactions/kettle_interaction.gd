extends StaticBody3D
signal water_spilled(amount: float)

@export var water_liters: float = 0.0
# Рекомендуемый безопасный объём.
@export var safe_water_liters: float = 1.5

# Физическая вместимость чайника.
@export var maximum_water_liters: float = 1.7

# Скорость вытекания лишней воды.
@export var overflow_speed: float = 0.4

@export var room_temperature: float = 20.0
@export var heating_speed: float = 8.0
@export var empty_heating_speed: float = 20.0
@export var cooling_speed: float = 3.0
@export var evaporation_speed: float = 0.04
@export var burn_temperature: float = 220.0
@export var boiling_feedback_temperature: float = 99.0
@export var whistle_volume_db: float = -20.0
@export var whistle_max_distance: float = 5.0

var temperature: float = 20.0
var is_held: bool = false
var is_burned: bool = false
var current_station: Node

var overflow_timer: float = 0.0
var total_spilled_water: float = 0.0

@onready var kettle: Node3D = get_parent()
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

@onready var body_mesh: MeshInstance3D = $"../Body"
@onready var steam_particles: GPUParticles3D = $"../SteamParticles"
@onready var smoke_particles: GPUParticles3D = $"../SmokeParticles"
@onready var whistle_player: AudioStreamPlayer3D = $"../WhistlePlayer"

@onready var overflow_spout_particles: GPUParticles3D = \
	$"../OverflowSpoutParticles"

@onready var overflow_lid_particles: GPUParticles3D = \
	$"../OverflowLidParticles"


var body_material: StandardMaterial3D


func _ready() -> void:
	add_to_group("kettles")
	temperature = room_temperature
	overflow_spout_particles.emitting = false
	overflow_lid_particles.emitting = false

	body_material = body_mesh.material_override as StandardMaterial3D

	if body_material == null:
		body_material = StandardMaterial3D.new()
	else:
		body_material = body_material.duplicate()

	body_mesh.material_override = body_material

	steam_particles.emitting = false
	smoke_particles.emitting = false
	whistle_player.volume_db = whistle_volume_db
	whistle_player.max_distance = whistle_max_distance

	var whistle_stream: AudioStreamOggVorbis = (
		whistle_player.stream as AudioStreamOggVorbis
	)
	if whistle_stream != null:
		whistle_stream.loop = true

	whistle_player.stop()
	_update_visuals()


func _physics_process(delta: float) -> void:
	if not is_burned:
		if _is_being_heated():
			_heat(delta)
		else:
			_cool(delta)

	_process_overflow(delta)
	_update_visuals()


func get_interaction_text() -> String:
	return (
		"[E] Взять чайник\n"
		+ "Вода: %.2f л | Температура: %.0f °C\n" % [
			water_liters,
			temperature
		]
		+ _get_state_text()
	)


func interact(interactor: Node) -> void:
	if is_held:
		return

	if interactor.has_method("pick_up_kettle"):
		interactor.pick_up_kettle(self)


func pick_up(hold_point: Marker3D) -> void:
	if current_station != null:
		current_station.remove_kettle(self)

	is_held = true
	collision_shape.disabled = true

	kettle.reparent(hold_point)
	kettle.position = Vector3.ZERO
	kettle.rotation = Vector3.ZERO


func put_down(parent_node: Node, target_transform: Transform3D) -> void:
	kettle.reparent(parent_node)
	kettle.global_transform = target_transform

	collision_shape.disabled = false
	is_held = false


func set_station(station: Node) -> void:
	current_station = station


func clear_station(station: Node) -> void:
	if current_station == station:
		current_station = null


func _is_being_heated() -> bool:
	if current_station == null:
		return false

	if not current_station.has_method("is_heating"):
		return false

	return current_station.is_heating()

func _heat(delta: float) -> void:
	if water_liters > 0.0:
		if temperature < 100.0:
			temperature += heating_speed * delta
			temperature = minf(temperature, 100.0)
		else:
			water_liters -= evaporation_speed * delta
			water_liters = maxf(water_liters, 0.0)

			if water_liters <= 0.0:
				print("Вода полностью выкипела")
	else:
		temperature += empty_heating_speed * delta
		temperature = minf(temperature, 300.0)

		if temperature >= burn_temperature:
			_burn()


func _cool(delta: float) -> void:
	temperature = move_toward(
		temperature,
		room_temperature,
		cooling_speed * delta
	)

func add_water(amount: float) -> void:
	if is_burned:
		return

	if amount <= 0.0:
		return

	var old_water: float = water_liters
	var requested_water: float = water_liters + amount
	var new_water: float = minf(
		requested_water,
		maximum_water_liters
	)

	var added_water: float = new_water - old_water
	var rejected_water: float = maxf(
		requested_water - maximum_water_liters,
		0.0
	)

	if added_water > 0.0:
		if old_water > 0.0:
			temperature = (
				temperature * old_water
				+ room_temperature * added_water
			) / new_water
		else:
			temperature = room_temperature

		water_liters = new_water

	if water_liters > safe_water_liters or rejected_water > 0.0:
		overflow_timer = 0.2
		total_spilled_water += rejected_water

		if rejected_water > 0.0:
			water_spilled.emit(rejected_water)

func _process_overflow(delta: float) -> void:
	if water_liters > safe_water_liters:
		var excess_water: float = water_liters - safe_water_liters
		var spilled_this_frame: float = minf(
			excess_water,
			overflow_speed * delta
		)

		water_liters -= spilled_this_frame
		total_spilled_water += spilled_this_frame
		water_spilled.emit(spilled_this_frame)
		overflow_timer = 0.2

	overflow_timer = maxf(
		overflow_timer - delta,
		0.0
	)

func _burn() -> void:
	if is_burned:
		return

	is_burned = true
	temperature = burn_temperature
	_update_visuals()

	print("Чайник сгорел")


func _get_state_text() -> String:
	if is_burned:
		return "Состояние: сгорел"

	if overflow_timer > 0.0:
		return "Состояние: переполняется (%.2f / %.2f л)" % [
			water_liters,
			safe_water_liters
		]

	if water_liters <= 0.0 and temperature >= 100.0:
		return "Состояние: перегревается"

	if water_liters <= 0.0:
		return "Состояние: пустой"

	if temperature >= 100.0:
		return "Состояние: вода кипит"

	if temperature >= 70.0:
		return "Состояние: вода почти закипела"

	if temperature > room_temperature + 1.0:
		return "Состояние: нагревается"

	return "Состояние: холодный"

func _should_emit_boiling_feedback() -> bool:
	return (
		not is_burned
		and water_liters > 0.0
		and temperature >= boiling_feedback_temperature
		and _is_being_heated()
	)


func _update_whistle(should_whistle: bool) -> void:
	if should_whistle and not whistle_player.playing:
		whistle_player.play()
	elif not should_whistle and whistle_player.playing:
		whistle_player.stop()


func _update_visuals() -> void:
	_update_body_color()

	var should_emit_boiling_feedback: bool = (
		_should_emit_boiling_feedback()
	)
	var should_emit_smoke: bool = is_burned or temperature >= 180.0
	var should_emit_overflow: bool = overflow_timer > 0.0

	steam_particles.emitting = should_emit_boiling_feedback
	_update_whistle(should_emit_boiling_feedback)
	smoke_particles.emitting = should_emit_smoke

	overflow_spout_particles.emitting = should_emit_overflow
	overflow_lid_particles.emitting = should_emit_overflow


func _update_body_color() -> void:
	if body_material == null:
		return

	var normal_color := Color("#AEB4B8")
	var hot_color := Color("#8A3528")
	var burned_color := Color("#171717")

	if is_burned:
		body_material.albedo_color = burned_color
		body_material.metallic = 0.15
		body_material.roughness = 0.85
		return

	if temperature <= 100.0:
		var warm_amount := inverse_lerp(
			room_temperature,
			100.0,
			temperature
		)

		body_material.albedo_color = normal_color.lerp(
			Color("#B78B7D"),
			warm_amount * 0.25
		)
	else:
		var overheat_amount := inverse_lerp(
			100.0,
			burn_temperature,
			temperature
		)

		body_material.albedo_color = hot_color.lerp(
			burned_color,
			overheat_amount
		)

	body_material.metallic = 0.75
	body_material.roughness = 0.3
