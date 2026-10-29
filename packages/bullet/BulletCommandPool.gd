class_name BulletCommandPool

const COMMAND_POOL_BLOCKS = 8

# Creates the command list required for us
# to render and compute bullet physics.

# It allows rollback from any arbritrary time
# and handles what bullets are inactive or active
# automatically.

var max_particles: Dictionary[String, int] = {}
var interval_list: Array[BulletInterval] = []
var blocks: Array[Array] = []
var length: float = 0.0

# Information that we need on command pool
# instantiations
var position: Vector2 = Vector2.ZERO
var theta: float = 0.0
var start: float = 0.0

var _wait_delay: float = 0.0
var _committed: bool = false

# Creates another command pool starting at `start`
# Also, this command pool must have been committed first
# in order to be duplicated!
func duplicate(start: float, position: Vector2, theta: float) -> BulletCommandPool:
	assert(_committed)
	
	var clone = BulletCommandPool.new()
	clone.blocks = blocks
	clone.interval_list = interval_list
	clone.max_particles = max_particles
	clone.length = length
	
	clone.start = start
	clone.position = position
	clone.theta = theta
	
	clone._committed = _committed
	clone._wait_delay = _wait_delay
	
	return clone

func _init() -> void:
	for i in range(COMMAND_POOL_BLOCKS):
		blocks.append([])

# Delays the creation of a bullet command
func wait(what: float) -> BulletCommandPool:
	_wait_delay += what
	return self

# Adds a bullet into the command list
func summon(kind: String, lifetime: float, path: Piecewise) -> BulletCommandPool:
	interval_list.append(BulletInterval.new(kind, _wait_delay, _wait_delay + lifetime, path))
	length = max(length, _wait_delay + lifetime + 1.0)
	return self

func commit() -> void:
	# Now, create the decomposed interval tree :3
	var active: Dictionary[String, Array] = {}
	for idx in range(interval_list.size()):
		var interval = interval_list[idx]
		
		var i = int(interval.start * COMMAND_POOL_BLOCKS / length)
		var j = int(interval.end * COMMAND_POOL_BLOCKS / length)
		for id in range(i, j + 1):
			if active.has(interval.kind):
				# If we had an active set, increment it!
				active[interval.kind][id] += 1
			else:
				# Otherwise, we have to create the active set here...
				var occupancy = []
				occupancy.resize(COMMAND_POOL_BLOCKS)
				occupancy[id] = 1
				active[interval.kind] = occupancy
			
			blocks[id].append(idx)
	
	# Now, we keep track of the upper bound of the possible active
	# bullets.
	for name in active.keys():
		var count = 0
		for bin in active[name]:
			count = max(count, bin)
		max_particles[name] = count
	_committed = true

func query_bullets(timer: float) -> Array[BulletInterval]:
	# This command pool must have been committed first
	# in order to function!
	assert(_committed)
	
	var block = int(timer * COMMAND_POOL_BLOCKS / length)
	var result: Array[BulletInterval] = []
	
	# Go through the interval :3
	for id in blocks[block]:
		var interval = interval_list[id]
		if interval.start <= timer and timer <= interval.end:
			result.append(interval)
	
	return result
