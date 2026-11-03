extends StaticBody3D

var placed_kettle: StaticBody3D

@onready var kettle_point: Marker3D = $KettlePoint


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
