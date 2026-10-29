extends Node2D

var object_pools: Dictionary[String, RenderObjectPool] = {}

var active_command_pools: Array[BulletCommandPool] = [] 

func add_object_pool(name: String, rect: TextureRect) -> void:
	# Testing for now, needs a proper scheduler
	# to handle object pooling soon.
	object_pools[name] = RenderObjectPool.new(rect, self)
	object_pools[name].try_allocate(128)

func add_command_pool(command_pool: BulletCommandPool, timer: float, position: Vector2, theta: float) -> void:
	active_command_pools.append(command_pool.duplicate(timer, position, theta))

func draw() -> void:
	# stub...
	return
