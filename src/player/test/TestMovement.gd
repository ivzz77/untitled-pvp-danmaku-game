extends Node2D

# Basic movement tester, it allows sub-frame inputs
# and such to occur
# magical

var movement: Movement
var input: int = 0

# Some basic input mappings
var keymap: Dictionary[Key, Movement.MovementEnum] = {
	Key.KEY_W: Movement.MovementEnum.UP,
	Key.KEY_A: Movement.MovementEnum.LEFT,
	Key.KEY_S: Movement.MovementEnum.DOWN,
	Key.KEY_D: Movement.MovementEnum.RIGHT,
	Key.KEY_SHIFT: Movement.MovementEnum.FOCUSING,
}

static func get_time_sec() -> float:
	return float(Time.get_ticks_usec()) / 1e6

func _ready() -> void:
	# Also, we allow sub-frame input
	Input.set_use_accumulated_input(false)
	movement = Movement.new(global_position)

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey): return
	
	var key = (event as InputEventKey).keycode
	if not keymap.has(key): return
	
	# Held or not held?
	var value = keymap[key]
	if event.is_pressed(): input |= value
	else: input &= ~value

	movement.update(input, get_time_sec())

func _physics_process(delta: float) -> void:
	global_position = movement.query_position(get_time_sec())
