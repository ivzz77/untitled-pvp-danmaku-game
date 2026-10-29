extends Node

const ZERO = Vector2.ZERO

func _ready() -> void:
	var pool = BulletCommandPool.new()
	
	for i in range(128):
		# Make a spiral pattern I guess :D 
		var theta = i / 32 * TAU
		var velocity = Vector2(cos(theta), sin(theta)) * 200
		
		pool.summon("generic_bullet", 2.0, Piecewise.new(ZERO, velocity, ZERO))
		pool.wait(max(1.0 - i / 32.0, 0.025))
	pool.commit()
