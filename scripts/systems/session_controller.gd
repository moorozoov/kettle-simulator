class_name SessionController
extends Node

signal state_changed(previous_state: SessionState, new_state: SessionState)

enum SessionState {
	RUNNING,
	SUCCESS,
	FAILURE,
}

const FULL_GOAL_TEXT: String = "Наполни чайник и безопасно вскипяти воду"
const COMPACT_GOAL_TEXT: String = "Цель: безопасно вскипятить воду"
const SUCCESS_TEXT: String = "Успех!\nВода вскипела, а нагрев безопасно остановлен."
const FAILURE_TEXT: String = "Провал\nЧайник сгорел."
const REAL_BOILING_TEMPERATURE: float = 100.0

var state: SessionState = SessionState.RUNNING
var has_reached_boiling: bool = false
var restart_pending: bool = false
var goal_is_compact: bool = false

@onready var player_camera: Camera3D = $"../PlayerCamera"
@onready var kettle: StaticBody3D = $"../Kettle/KettleInteraction"
@onready var burner: StaticBody3D = $"../Burner/BurnerInteraction"
@onready var sink: StaticBody3D = $"../Sink/SinkInteraction"
@onready var goal_hint: Label = $"../UI/GoalHint"
@onready var result_overlay: Control = $"../UI/ResultOverlay"
@onready var result_label: Label = $"../UI/ResultOverlay/Panel/Content/ResultLabel"
@onready var restart_button: Button = $"../UI/ResultOverlay/Panel/Content/RestartButton"


func _ready() -> void:
	restart_button.pressed.connect(request_restart)
	goal_hint.text = FULL_GOAL_TEXT
	goal_hint.show()
	result_overlay.hide()


func _physics_process(_delta: float) -> void:
	if state != SessionState.RUNNING:
		return

	_update_goal_hint()
	_evaluate_session()


func _unhandled_input(event: InputEvent) -> void:
	if state == SessionState.RUNNING:
		return

	if event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.pressed and not key_event.echo and key_event.physical_keycode == KEY_R:
			request_restart()
			get_viewport().set_input_as_handled()


func _evaluate_session() -> void:
	if state != SessionState.RUNNING:
		return

	# Failure wins if burning and a safe reaction happen on the same frame.
	if kettle.get("is_burned") as bool:
		_finish_session(SessionState.FAILURE)
		return

	var water_liters: float = kettle.get("water_liters") as float
	var temperature: float = kettle.get("temperature") as float
	var is_being_heated: bool = kettle.call("_is_being_heated") as bool

	if (
		water_liters > 0.0
		and temperature >= REAL_BOILING_TEMPERATURE
		and is_being_heated
	):
		has_reached_boiling = true

	if has_reached_boiling and water_liters > 0.0 and not is_being_heated:
		_finish_session(SessionState.SUCCESS)


func request_restart() -> void:
	if state == SessionState.RUNNING or restart_pending:
		return

	restart_pending = true
	get_tree().reload_current_scene()


func _finish_session(new_state: SessionState) -> void:
	if state != SessionState.RUNNING:
		return

	var previous_state: SessionState = state
	state = new_state
	goal_hint.hide()
	result_label.text = SUCCESS_TEXT if state == SessionState.SUCCESS else FAILURE_TEXT
	result_overlay.show()
	restart_button.grab_focus()
	player_camera.set_process_unhandled_input(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	state_changed.emit(previous_state, state)


func _update_goal_hint() -> void:
	if goal_is_compact:
		return

	var meaningful_action: bool = (
		(kettle.get("is_held") as bool)
		or (kettle.get("water_liters") as float) > 0.0
		or (burner.get("is_turned_on") as bool)
		or (sink.get("water_is_on") as bool)
	)

	if meaningful_action:
		goal_is_compact = true
		goal_hint.text = COMPACT_GOAL_TEXT
