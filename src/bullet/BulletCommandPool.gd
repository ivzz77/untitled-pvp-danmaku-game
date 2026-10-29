class_name BulletCommandPool

const COMMAND_POOL_BLOCKS = 8

# The command pool basically orchestrates what bullets
# will be shot during an attack. It is very generic, and
# allows rollback from any arbritrary time and handles
# what bullets are inactive or active automatically.

class BulletProxy:
	# Structure to hold the interval data. I did it this way
	# so we don't have to create a dictionary every single time
	# we request a BulletProxy LOL

	var piecewise: Piecewise
	var center: float
	var start: float
	
	var kind: Bullet.BulletKind
	var end: float

	func _init(_kind: Bullet.BulletKind, _start: float, _end: float, _piecewise: Piecewise) -> void:
		self.piecewise = _piecewise
		self.center = (_start + _end) * 0.5
		self.start = _start
		self.kind = _kind
		self.end = _end

class BulletResult:
	# Structure to hold information about the position
	# and timing of the bullet interval
	var position: Vector4
	var start: float
	
	var kind: Bullet.BulletKind
	var end: float
	
	func _init(bullet: BulletProxy, _position: Vector4, _start: float) -> void:
		self.position = _position
		self.start = bullet.start + _start
		self.end = bullet.end + _start
		self.kind = bullet.kind

var max_particles: Dictionary[Bullet.BulletKind, int] = {}
var interval_list: Array[BulletProxy] = []
var blocks: Array[Array] = []
var length: float = 0.0

# Information that we need on command pool
# instantiations
var position: Vector2 = Vector2.ZERO
var theta: float = 0.0
var start: float = 0.0
var end: float = 0.0

var _wait_delay: float = 0.0
var _committed: bool = false

# Creates another command pool starting at `start`
# Also, this command pool must have been committed first
# in order to be duplicated!
func duplicate(_start: float, _position: Vector2, _theta: float) -> BulletCommandPool:
	assert(_committed)
	
	var clone = BulletCommandPool.new()
	clone.blocks = blocks
	clone.interval_list = interval_list
	clone.max_particles = max_particles
	clone.length = length
	
	clone.start = _start
	clone.position = _position
	clone.theta = _theta
	clone.end = _start + length
	
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
func summon(kind: Bullet.BulletKind, lifetime: float, path: Piecewise) -> BulletCommandPool:
	interval_list.append(BulletProxy.new(kind, _wait_delay, _wait_delay + lifetime, path))
	length = max(length, _wait_delay + lifetime + 1.0)
	return self

func commit() -> BulletCommandPool:
	# Now, create the decomposed interval tree :3
	var active: Dictionary[Bullet.BulletKind, Array] = {}
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
				occupancy.fill(0)
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
	return self

func query_bullets(timer: float) -> Array[BulletResult]:
	# This command pool must have been committed first
	# in order to function!
	assert(_committed)
	
	var t = timer - start
	var block = int(t * COMMAND_POOL_BLOCKS / length)
	var result: Array[BulletResult] = []
	
	# Go through the interval :3
	var cos_theta = cos(theta)
	var sin_theta = sin(theta)
	for id in blocks[block]:
		var interval = interval_list[id]
		if interval.start > t or t >= interval.end: continue
		
		# Also, we do a transform matrix evaluation of the position and velocity
		# components. So, let R = [ cos, -sin ; sin cos ]
		# p' = R * p_local + position
		# v' = R * v_local
		
		var local_trs = interval.piecewise.eval(t - interval.start)
		var final_position = Vector4(
			# Position components
			local_trs.x * cos_theta - local_trs.y * sin_theta + position.x,
			local_trs.y * cos_theta + local_trs.x * sin_theta + position.y,
			
			# Velocity components
			local_trs.z * cos_theta - local_trs.w * sin_theta,
			local_trs.w * cos_theta + local_trs.z * sin_theta)
		
		result.append(BulletResult.new(interval, final_position, start))
	
	return result
