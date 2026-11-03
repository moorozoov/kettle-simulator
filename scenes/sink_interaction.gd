extends StaticBody3D

@export var filling_speed: float = 0.25

# Сколько воды помещается на столе до начала стекания.
@export var floor_spill_threshold: float = 0.75

# К этому объёму лужа занимает весь пол.
@export var floor_puddle_full_threshold: float = 10.0

# После этого объёма начинает подниматься уровень воды.
@export var room_flood_threshold: float = 12.0

# Финальный масштаб круглой лужи должен перекрывать диагональ комнаты.
@export var floor_puddle_cover_scale: float = 6.0

# До этой высоты слой затопления перекрывает лужу без резкой подмены.
@export var puddle_blend_height: float = 0.02

# Внутренняя площадь пола: 5.9 x 5.9 м.
@export var room_floor_area_m2: float = 34.81

# Ускоряет только визуальный подъём воды для игрового темпа.
# При значении 1.0 высота соответствовала бы реальному объёму.
@export var flood_visual_multiplier: float = 600.0

# Максимальная визуальная высота воды в комнате.
@export var maximum_flood_height: float = 0.35

var water_is_on: bool = false
var placed_kettle: StaticBody3D

var unattended_spilled_water: float = 0.0
var floor_puddle_start_position: Vector3

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
	room_flood_water.visible = false
	floor_puddle_start_position = floor_puddle.position


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
	var linear_counter_ratio: float = clampf(
		unattended_spilled_water
		/ maxf(floor_spill_threshold, 0.01),
		0.0,
		1.0
	)
	var counter_ratio: float = smoothstep(
		0.0,
		1.0,
		linear_counter_ratio
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

	var puddle_range: float = maxf(
		floor_puddle_full_threshold
		- floor_spill_threshold,
		0.01
	)

	var linear_floor_ratio: float = clampf(
		floor_water / puddle_range,
		0.0,
		1.0
	)
	var floor_ratio: float = smoothstep(
		0.0,
		1.0,
		linear_floor_ratio
	)

	# Радиус исходного цилиндра равен 0.75 м. Финальный размер
	# перекрывает не только ширину комнаты, но и её диагональ.
	var floor_size: float = lerpf(
		0.08,
		maxf(floor_puddle_cover_scale, 0.08),
		floor_ratio
	)

	var water_reached_floor: bool = floor_water > 0.0
	var room_is_flooding: bool = (
		unattended_spilled_water
		>= room_flood_threshold
	)

	table_drip.visible = water_reached_floor
	floor_puddle.visible = water_reached_floor

	var floor_center: Vector3 = Vector3(
		0.0,
		floor_puddle_start_position.y,
		0.0
	)
	floor_puddle.position = floor_puddle_start_position.lerp(
		floor_center,
		floor_ratio
	)

	floor_puddle.scale = Vector3(
		floor_size,
		1.0,
		floor_size
	)

	var flood_water: float = maxf(
		unattended_spilled_water
		- room_flood_threshold,
		0.0
	)
	var flood_height: float = _calculate_flood_height(
		flood_water
	)

	room_flood_water.visible = room_is_flooding

	# Не убираем старую лужу в первый кадр затопления: новый слой
	# сначала незаметно поднимается поверх неё.
	if (
		room_is_flooding
		and flood_height >= maxf(puddle_blend_height, 0.0)
	):
		floor_puddle.visible = false

	if room_is_flooding:
		# Не допускаем нулевой толщины меша в первый кадр.
		var visible_height: float = maxf(
			flood_height,
			0.004
		)

		room_flood_water.scale = Vector3(
			1.0,
			visible_height,
			1.0
		)

		room_flood_water.position.y = (
			visible_height * 0.5
			+ 0.005
		)


func _calculate_flood_height(flood_water_liters: float) -> float:
	var safe_room_area: float = maxf(
		room_floor_area_m2,
		0.01
	)
	var visual_water_liters: float = (
		flood_water_liters
		* maxf(flood_visual_multiplier, 0.0)
	)

	# 1 м³ = 1000 литров; высота = объём / площадь.
	var calculated_height: float = (
		visual_water_liters
		/ 1000.0
		/ safe_room_area
	)

	return clampf(
		calculated_height,
		0.0,
		maxf(maximum_flood_height, 0.0)
	)
