class_name BulletRenderer

# magical

var object_pools: Dictionary[Bullet.BulletKind, RenderObjectPool] = {}
var active_command_pools: IntervalArray = IntervalArray.new()

var parent: Node2D

func _init(_parent: Node2D) -> void:
	self.parent = _parent

func add_object_pool(name: Bullet.BulletKind, rect: Sprite2D) -> void:
	# Testing for now, needs a proper scheduler
	# to handle object pooling soon.
	object_pools[name] = RenderObjectPool.new(rect, self.parent)
	object_pools[name].try_allocate(256)

func add_command_pool(command_pool: BulletCommandPool, timer: float, position: Vector2, theta: float) -> void:
	assert(command_pool._committed)
	active_command_pools.insert(timer, timer + command_pool.length, command_pool.duplicate(timer, position, theta))

func draw(timer: float) -> void:
	for cmd_pool in active_command_pools.advance(timer):
		# Add bullets we find...
		for bullet in cmd_pool.query_bullets(timer):
			object_pools[bullet.kind].draw_bullet(bullet, timer)
	
	# Finalize the object pools
	for pool in object_pools.values():
		pool.commit()
