extends Node2D

const ZERO = Vector2.ZERO
var renderer: BulletRenderer

@export var circle_sprite: Sprite2D
@export var heart_sprite: Sprite2D
@export var wide_sprite: Sprite2D

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
			pool.summon(Bullet.BulletKind.WIDE, 3.0, Piecewise.new(right * (i - half) * space + offset, velocity, ZERO))

	pool.commit()
	return pool
	
func prepare_spiral(n: int) -> BulletCommandPool:
	var pool = BulletCommandPool.new()
	for i in range(128):
		# Make a spiral pattern I guess :D 
		var theta = (i * TAU) / 32.0
		var velocity = Vector2.from_angle(theta) * 300
		pool.summon(Bullet.BulletKind.CIRCLE, 6.0, Piecewise.new(ZERO, velocity, ZERO))
		pool.wait(max(0.1 - i / 32.0, 0.025))

	pool.commit()
	return pool

func prepare_hearts(n: int, m: int, delay: float) -> BulletCommandPool:
	var pool = BulletCommandPool.new()
	
	for i in range(n):
		var phase = i / 4.2
		for j in range(m):
			# Make a spiral pattern I guess :D 
			var theta = (j * TAU) / m + phase
			var velocity = Vector2.from_angle(theta) * 800
			pool.summon(Bullet.BulletKind.HEART, 2.0, Piecewise.new(ZERO, velocity, ZERO))
		pool.wait(delay)
	
	pool.commit()
	return pool
	
func _ready() -> void:
	renderer = BulletRenderer.new(self)
	renderer.add_object_pool(Bullet.BulletKind.CIRCLE, circle_sprite)
	renderer.add_object_pool(Bullet.BulletKind.HEART, heart_sprite)
	renderer.add_object_pool(Bullet.BulletKind.WIDE, wide_sprite)
	
	var t = float(Time.get_ticks_usec()) / 1e6
	renderer.add_command_pool(prepare_spiral(32), t + 1.0, global_position, 0.0)
	renderer.add_command_pool(prepare_hearts(5, 8, 0.4), t + 5.0, global_position, 0.0)
	renderer.add_command_pool(prepare_pyramid(10, ZERO, 64, 5, 500), t + 6.0, global_position, 0.0)

func _physics_process(delta: float) -> void:
	var t = float(Time.get_ticks_usec()) / 1e6
	renderer.draw(t)
