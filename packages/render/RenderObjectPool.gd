class_name RenderObjectPool

# RenderObjectPool is responsible for rendering the various bullets on screen.

const DEFAULT_MAX_LIFETIME = 0.2
const FADE_TIME = 0.2

const INITIAL_CAPACITY = 8
const UNUSED = Vector2.ONE * 1e7

var _original_scale: Vector2
var _capacity: int = 0
var _visible: int = 0
var _cursor: int = 0

var _pool: Array[TextureRect] = []
var _parent: Node2D
var _rect: TextureRect

func _init(rect: TextureRect, parent: Node2D) -> void:
	_original_scale = rect.scale
	_parent = parent
	_rect = rect
	try_allocate(INITIAL_CAPACITY)

# Call this at the beginning of a frame
func reset_cursor() -> void:
	# We go back to the beginning
	_cursor = 0

# Draws a bullet given that timer is the current client timer
func draw_bullet(bullet: BulletInterval, timer: float) -> void:
	var object = _pool[_cursor]
	assert(_cursor < _capacity)
	_cursor += 1
	
	var t = timer - bullet.start
	if t < FADE_TIME:
		# If we're spawning in, play the spawn transition and also
		# scale the bullet visually by it. Basically, your standard
		# Touhou bullet spawn effect
		object.scale = _original_scale * (1 + (1.0 - t / FADE_TIME))
		object.modulate.a = smoothstep(0, 1, t / FADE_TIME)
	elif timer > bullet.end - FADE_TIME:
		# If we're despawning, play the despawn transition
		object.modulate.a = smoothstep(1, 0, (timer - bullet.end + FADE_TIME) / FADE_TIME) 
	
	object.global_position = bullet.piecewise.eval(t)

# Sets the amount of visible bullets
func commit() -> void:
	if _visible > _cursor:
		# We are setting less objects to be visible,
		# so we must make some of these objects unused.
		for i in range(_cursor - _visible):
			_pool[_visible - i].global_position = UNUSED
	_visible = _cursor
	
func try_allocate(amount: int) -> void:
	# We won't increase the capacity
	# iff capacity doesn't increase.
	for i in range(amount):
		var clone = _rect.duplicate()
		clone.global_position = UNUSED
		_parent.add_child(clone)
		_pool.append(clone)
	_capacity += amount
