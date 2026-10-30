class_name Movement

# Player movement system, where player state is determined by a bitflag
# Note that we check the previous time from releasing/holding an input key
# and the lack of delta time or stepping. This is on purpose, we need this
# for deterministic networking :d
# magical

const ATTACK_SPEED_MULTIPLIER = 0.5
const ATTACK_FOCUSING_MULTIPLIER = 0.333

enum MovementEnum {
	UP = 0x1, LEFT = 0x2, DOWN = 0x4, RIGHT = 0x8,
	ATTACKING = 0x10, FOCUSING = 0x20,
}

var _last_position: Vector2 = Vector2(0, 0)
var _last_timer: float = 0.0

var border_size: Vector2 = Vector2(1920, 1080)
var hitbox_size: Vector2 = Vector2.ONE * 100.0

var base_speed: float = 800.0
var state: MovementEnum = 0

func _init(position: Vector2) -> void:
	_last_position = position

# Checks if we need to change the movement enum at all
# If so, we update the position with respect to that time
func update(input: MovementEnum, timer: float) -> void:
	if state == input: return
	
	_last_position = query_position(timer)
	_last_timer = timer
	state = input

# Gets the current position of the player given
# the current state
func query_position(timer: float) -> Vector2:
	# Check movement multipliers
	var multiplier = 1.0
	if (state & MovementEnum.ATTACKING) != 0: multiplier = ATTACK_SPEED_MULTIPLIER
	if (state & MovementEnum.FOCUSING) != 0: multiplier = ATTACK_FOCUSING_MULTIPLIER
	
	var speed = base_speed * multiplier
	var wish_direction = Vector2.ZERO
	
	# Yeah...
	if (state & MovementEnum.RIGHT) != 0: wish_direction += Vector2.RIGHT
	if (state & MovementEnum.LEFT) != 0: wish_direction -= Vector2.RIGHT
	if (state & MovementEnum.DOWN) != 0: wish_direction -= Vector2.UP
	if (state & MovementEnum.UP) != 0: wish_direction += Vector2.UP

	var dt = timer - _last_timer
	var wish_position = _last_position + wish_direction.limit_length(1.0) * speed * dt
	wish_position = wish_position.clamp((hitbox_size - border_size) * 0.5, (border_size - hitbox_size) * 0.5)
	return wish_position
