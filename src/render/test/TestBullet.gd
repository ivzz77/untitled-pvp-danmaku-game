extends Node2D

# Note, this is a testing suite!
# This is not actually meant to be an actual version of it
# although, we may reuse some of the utility functions here!

const ZERO = Vector2.ZERO
var renderer: BulletRenderer

@export var circle_sprite: Sprite2D
@export var heart_sprite: Sprite2D
@export var small_sprite: Sprite2D
@export var wide_sprite: Sprite2D

static func get_time_sec() -> float:
	return float(Time.get_ticks_usec()) / 1e6

func prepare_zigzag(n: int, count: int, radius: float, speed: float, w: float, spacing: float, delay: float) -> BulletCommandPool:
	var pool = BulletCommandPool.new()
	for j in range(count):
		for i in range(n):
			var direction = Vector2.from_angle((i * TAU) / float(n))
			var right = Vector2(-direction.y, direction.x)
			var velocity = direction * speed
			pool.summon(Bullet.BulletKind.WIDE, 3.0,
				Piecewise.new(func(t: float) -> Vector4:
					var phase = t * 5
					return Piecewise.transform(velocity * t + right * acos(cos(phase)) * spacing, velocity)))
			pool.wait(0.02)
	return pool.commit()
	
func prepare_circle_circle(n: int, count: int, radius: float, speed: float, w: float, spacing: float, delay: float) -> BulletCommandPool:
	var pool = BulletCommandPool.new()
	for i in range(n):
		var direction = Vector2.from_angle((i * TAU) / float(n))
		for j in range(count):
			var theta = (j * TAU) / float(4.5)
			var velocity = direction * speed
			pool.summon(Bullet.BulletKind.SMALL, 3.0,
				Piecewise.new(func(t: float) -> Vector4:
					var phase = t * w + theta
					var offset = Vector2.from_angle(phase)
					
					var phase_radius = sin(t * w) * 100 + radius
					return Piecewise.transform(velocity * t + offset * phase_radius, velocity)))
		pool.wait(delay)
	return pool.commit()

func prepare_pyramid(n: int, offset: Vector2, space: int, count: int, speed: float) -> BulletCommandPool:
	var pool = BulletCommandPool.new()
	var half = count >> 1
	
	for j in range(n):
		var theta = (j * TAU) / float(n)
		
		var direction = Vector2.from_angle(theta)
		var right = Vector2(-direction.y, direction.x)
		
		for i in range(count):
			var distance = abs(i - half)
			var velocity = direction * (speed - distance * 30)
			pool.summon(Bullet.BulletKind.WIDE, 3.0, Piecewise.pv(right * (i - half) * space + offset, velocity))

	return pool.commit()
	
func prepare_spiral(n: int) -> BulletCommandPool:
	var pool = BulletCommandPool.new()
	for i in range(128):
		# Make a spiral pattern I guess :D 
		var theta = (i * TAU) / 32.0
		var velocity = Vector2.from_angle(theta) * 300
		pool.summon(Bullet.BulletKind.CIRCLE, 6.0, Piecewise.pv(ZERO, velocity))
		pool.wait(max(0.1 - i / 32.0, 0.025))

	return pool.commit()

func prepare_hearts(n: int, m: int, delay: float) -> BulletCommandPool:
	var pool = BulletCommandPool.new()
	
	for i in range(n): 
		var phase = i / 4.2
		for j in range(m):
			# Make a spiral pattern I guess :D 
			var theta = (j * TAU) / m + phase
			var velocity = Vector2.from_angle(theta) * 800
			pool.summon(Bullet.BulletKind.HEART, 2.0, Piecewise.pv(ZERO, velocity))
		pool.wait(delay)
	
	return pool.commit()
	
func _ready() -> void:
	renderer = BulletRenderer.new(self)
	renderer.add_object_pool(Bullet.BulletKind.CIRCLE, circle_sprite)
	renderer.add_object_pool(Bullet.BulletKind.HEART, heart_sprite)
	renderer.add_object_pool(Bullet.BulletKind.SMALL, small_sprite)
	renderer.add_object_pool(Bullet.BulletKind.WIDE, wide_sprite)
	
	var t = get_time_sec()
	renderer.add_command_pool(prepare_spiral(32), t + 1.0, global_position, 0.0)
	renderer.add_command_pool(prepare_hearts(5, 8, 0.4), t + 5.0, global_position, 0.0)
	renderer.add_command_pool(prepare_pyramid(10, ZERO, 64, 5, 500), t + 6.0, global_position, 0.0)
	renderer.add_command_pool(prepare_circle_circle(16, 10, 62, 400, 1, 240, 0.1), t + 7.0, global_position, 0.0)
	renderer.add_command_pool(prepare_zigzag(8, 10, 62, 400, 1, 50, 0.5), t + 8.0, global_position, 0.0)

func _physics_process(delta: float) -> void:
	renderer.draw(get_time_sec())
