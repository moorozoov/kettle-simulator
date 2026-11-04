extends Camera3D

@export var mouse_sensitivity: float = 0.002
@export var minimum_pitch: float = -45.0
@export var maximum_pitch: float = 30.0
@export var maximum_yaw: float = 55.0

var initial_yaw: float
var current_interactable: Object
var held_kettle: StaticBody3D
var kettle_original_parent: Node
var kettle_original_transform: Transform3D

@onready var interaction_ray: RayCast3D = $InteractionRay
@onready var hold_point: Marker3D = $HoldPoint
@onready var interaction_prompt: Label = $"../UI/HUD/InteractionPrompt"


func _ready() -> void:
	initial_yaw = rotation.y
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interaction_prompt.hide()


func _physics_process(_delta: float) -> void:
	_update_interaction()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotation.y -= event.relative.x * mouse_sensitivity
			rotation.y = clamp(
				rotation.y,
				initial_yaw - deg_to_rad(maximum_yaw),
				initial_yaw + deg_to_rad(maximum_yaw)
			)

			rotation.x -= event.relative.y * mouse_sensitivity
			rotation.x = clamp(
				rotation.x,
				deg_to_rad(minimum_pitch),
				deg_to_rad(maximum_pitch)
			)

	if event.is_action_pressed("interact"):
		if held_kettle != null:
			_try_place_kettle()
		elif current_interactable != null:
			current_interactable.interact(self)

		_update_interaction()

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			get_tree().quit()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func pick_up_kettle(kettle_interaction: StaticBody3D) -> void:
	if held_kettle != null:
		return

	held_kettle = kettle_interaction
	kettle_original_parent = kettle_interaction.get_parent().get_parent()
	kettle_original_transform = kettle_interaction.get_parent().global_transform

	kettle_interaction.pick_up(hold_point)


func _try_place_kettle() -> void:
	if held_kettle == null:
		return

	if current_interactable == null:
		return

	if not current_interactable.has_method("can_place_kettle"):
		return

	if not current_interactable.can_place_kettle():
		return

	var placement_transform: Transform3D = \
		current_interactable.get_kettle_placement_transform()

	var kettle_to_place := held_kettle
	held_kettle = null

	kettle_to_place.put_down(
		kettle_original_parent,
		placement_transform
	)

	current_interactable.register_kettle(kettle_to_place)


func _update_interaction() -> void:
	current_interactable = null
	interaction_prompt.hide()

	if not interaction_ray.is_colliding():
		if held_kettle != null:
			interaction_prompt.text = \
				"Наведите прицел на плиту, раковину или столешницу"
			interaction_prompt.show()
		return

	var collider := interaction_ray.get_collider()

	if collider == null:
		return

	if held_kettle != null:
		if collider.has_method("can_place_kettle"):
			if collider.can_place_kettle():
				current_interactable = collider
				interaction_prompt.text = "[E] Поставить чайник"
				interaction_prompt.show()
			return

		interaction_prompt.text = \
			"Наведите прицел на плиту, раковину или столешницу"
		interaction_prompt.show()
		return

	if collider.has_method("interact") and collider.has_method("get_interaction_text"):
		current_interactable = collider
		interaction_prompt.text = collider.get_interaction_text()
		interaction_prompt.show()
