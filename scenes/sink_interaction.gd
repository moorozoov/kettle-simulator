extends StaticBody3D

@export var filling_speed: float = 0.25

# Сколько воды помещается на столе до начала стекания.
@export var floor_spill_threshold: float = 0.75

# Сколько литров нужно для максимального размера лужи на полу.
@export var maximum_floor_spill: float = 3.0

# После этого объёма лужа занимает почти весь пол.
@export var room_flood_threshold: float = 10.0

# Объём, соответствующий максимальной визуальной высоте.
@export var maximum_visual_flood: float = 100.0

# Максимальная визуальная высота воды в комнате.
@export var maximum_flood_height: float = 0.35

var water_is_on: bool = false
var placed_kettle: StaticBody3D

var unattended_spilled_water: float = 0.0

@onready var kettle_point: Marker3D = $"../KettlePoint"
@onready var water_stream: MeshInstance3D = $"../WaterStream"
@onready var room_flood_water: MeshInstance3D = \
	$"../../RoomFloodWater"

@onready var counter_puddle: MeshInstance3D = \
	$"../../CounterPuddle"

@onready var table_drip: MeshInstance3D = \
	$"../../TableDrip"

@onready var floor_puddle: MeshInstance3D = \
	$"../../FloorPuddle"


func _ready() -> void:
	water_stream.visible = false
	counter_puddle.visible = false
	table_drip.visible = false
	floor_puddle.visible = false


func _physics_process(delta: float) -> void:
	if not water_is_on:
		return

	if placed_kettle != null:
		placed_kettle.add_water(filling_speed * delta)
	else:
		_spill_unattended_water(filling_speed * delta)


func get_interaction_text() -> String:
	if water_is_on:
		if placed_kettle == null:
			return (
				"[E] Выключить воду\n"
				+ "Вода льётся на стол: %.2f л" \
				% unattended_spilled_water
			)

		return "[E] Выключить воду"

	return "[E] Включить воду"


func interact(_interactor: Node) -> void:
	water_is_on = not water_is_on
	water_stream.visible = water_is_on

	if water_is_on:
		print("Вода включена")
	else:
		print("Вода выключена")


func can_place_kettle() -> bool:
	return placed_kettle == null


func get_kettle_placement_transform() -> Transform3D:
	return kettle_point.global_transform


func register_kettle(kettle_interaction: StaticBody3D) -> void:
	placed_kettle = kettle_interaction
	kettle_interaction.set_station(self)

	var spill_callback := Callable(
		self,
		"_on_kettle_water_spilled"
	)

	if kettle_interaction.has_signal("water_spilled"):
		if not kettle_interaction.is_connected(
			"water_spilled",
			spill_callback
		):
			kettle_interaction.connect(
				"water_spilled",
				spill_callback
			)


func remove_kettle(kettle_interaction: StaticBody3D) -> void:
	if placed_kettle != kettle_interaction:
		return

	var spill_callback := Callable(
		self,
		"_on_kettle_water_spilled"
	)

	if kettle_interaction.has_signal("water_spilled"):
		if kettle_interaction.is_connected(
			"water_spilled",
			spill_callback
		):
			kettle_interaction.disconnect(
				"water_spilled",
				spill_callback
			)

	placed_kettle.clear_station(self)
	placed_kettle = null

func _on_kettle_water_spilled(amount: float) -> void:
	_spill_unattended_water(amount)

func _spill_unattended_water(amount: float) -> void:
	if amount <= 0.0:
		return

	unattended_spilled_water += amount
	_update_spill_visuals()


func _update_spill_visuals() -> void:
	var counter_ratio: float = clampf(
		unattended_spilled_water / floor_spill_threshold,
		0.0,
		1.0
	)

	var counter_size: float = lerpf(
		0.08,
		1.0,
		counter_ratio
	)

	counter_puddle.visible = unattended_spilled_water > 0.01
	counter_puddle.scale = Vector3(
		counter_size,
		1.0,
		counter_size * 0.75
	)

	var floor_water: float = maxf(
		unattended_spilled_water - floor_spill_threshold,
		0.0
	)

	var puddle_range: float = (
		room_flood_threshold
		- floor_spill_threshold
	)

	var floor_ratio: float = clampf(
		floor_water / puddle_range,
		0.0,
		1.0
	)

	# Радиус исходного цилиндра равен 0.75 м.
	# Scale 4 даёт лужу диаметром около 6 метров.
	var floor_size: float = lerpf(
		0.08,
		4.0,
		floor_ratio
	)

	var water_reached_floor: bool = floor_water > 0.0
	var room_is_flooding: bool = (
		unattended_spilled_water
		>= room_flood_threshold
	)

	table_drip.visible = water_reached_floor
	floor_puddle.visible = (
		water_reached_floor
		and not room_is_flooding
	)

	floor_puddle.scale = Vector3(
		floor_size,
		1.0,
		floor_size * 0.85
	)

	var flood_water: float = maxf(
		unattended_spilled_water
		- room_flood_threshold,
		0.0
	)

	var flood_range: float = maxf(
		maximum_visual_flood
		- room_flood_threshold,
		0.01
	)

	var flood_ratio: float = clampf(
		flood_water / flood_range,
		0.0,
		1.0
	)

	var flood_height: float = lerpf(
		0.01,
		maximum_flood_height,
		flood_ratio
	)

	room_flood_water.visible = room_is_flooding

	if room_is_flooding:
		room_flood_water.scale = Vector3(
			1.0,
			flood_height,
			1.0
		)

		room_flood_water.position.y = (
			flood_height * 0.5
			+ 0.005
		)
