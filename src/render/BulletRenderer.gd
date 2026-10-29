class_name BulletRenderer

var object_pools: Dictionary[Bullet.BulletKind, RenderObjectPool] = {}
var active_command_pools: Array[BulletCommandPool] = []
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
	active_command_pools.append(command_pool.duplicate(timer, position, theta))

func draw(timer: float) -> void:
	# Draw the bullets
	var remove_list = []
	for idx in range(active_command_pools.size() -1, -1, -1):
		var cmd_pool = active_command_pools[idx]
		if cmd_pool.start > timer:
			# We can't see it yet, so don't do anything
			continue
		elif cmd_pool.end <= timer:
			remove_list.append(idx)
			timer = cmd_pool.end - 0.01
			
		# Add bullets we find...
		for bullet in cmd_pool.query_bullets(timer):
			object_pools[bullet.kind].draw_bullet(bullet, timer)
	
	# Remove the active command pools being rendered
	for idx in remove_list:
		active_command_pools.remove_at(idx)
	
	# Finalize the object pools
	for pool in object_pools.values():
		pool.commit()
