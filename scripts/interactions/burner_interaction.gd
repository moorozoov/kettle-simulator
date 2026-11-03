extends StaticBody3D

var is_turned_on: bool = false
var placed_kettle: StaticBody3D

@onready var burner_mesh: MeshInstance3D = get_parent() as MeshInstance3D
@onready var kettle_point: Marker3D = $"../KettlePoint"


func _ready() -> void:
	if burner_mesh.material_override:
		burner_mesh.material_override = burner_mesh.material_override.duplicate()

	_update_appearance()
	call_deferred("_register_initial_kettle")


func get_interaction_text() -> String:
	if is_turned_on:
		return "[E] Выключить конфорку"

	return "[E] Включить конфорку"


func interact(_interactor: Node) -> void:
	is_turned_on = not is_turned_on
	_update_appearance()

	if is_turned_on:
		print("Конфорка включена")
	else:
		print("Конфорка выключена")


func can_place_kettle() -> bool:
	return placed_kettle == null


func get_kettle_placement_transform() -> Transform3D:
	return kettle_point.global_transform


func register_kettle(kettle_interaction: StaticBody3D) -> void:
	placed_kettle = kettle_interaction
	kettle_interaction.set_station(self)


func remove_kettle(kettle_interaction: StaticBody3D) -> void:
	if placed_kettle != kettle_interaction:
		return

	placed_kettle.clear_station(self)
	placed_kettle = null

func is_heating() -> bool:
	return is_turned_on

func _register_initial_kettle() -> void:
	var kettles := get_tree().get_nodes_in_group("kettles")

	if kettles.is_empty():
		return

	register_kettle(kettles[0] as StaticBody3D)


func _update_appearance() -> void:
	var material := burner_mesh.material_override as StandardMaterial3D

	if material == null:
		material = StandardMaterial3D.new()
		burner_mesh.material_override = material

	if is_turned_on:
		material.albedo_color = Color("#D83A20")
		material.emission_enabled = true
		material.emission = Color("#FF3B18")
		material.emission_energy_multiplier = 2.0
	else:
		material.albedo_color = Color("#090909")
		material.emission_enabled = false
