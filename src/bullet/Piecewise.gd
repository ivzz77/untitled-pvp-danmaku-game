class_name Piecewise

# Represents a piecewise function!!
# The way this works is that you provide it
# some initial position, velocity, acceleration for the main constructor
# However, after that, you can add new positions (this will respect the last calculated position)
# Also, we return a Vector4 because it encodes the position and velocity. We use these
# values specifically for telling where a bullet goes
# magical

var funcs: Array[Callable] = []
var times: Array[int] = []

static func transform(what: Vector2, velocity: Vector2) -> Vector4:
	return Vector4(what.x, what.y, velocity.x, velocity.y)

static func pva(p: Vector2, v: Vector2, a: Vector2) -> Piecewise:
	return Piecewise.new(func(t: float) -> Vector4: return transform(p + v * t + a * t * t * 0.5, v))

static func pv(p: Vector2, v: Vector2) -> Piecewise:
	return Piecewise.new(func(t: float) -> Vector4: return transform(p + v * t, v))

func _init(initial: Callable):
	times.append(0)
	funcs.append(initial)
	pass

# Adds to the callable list...
func add(sec: float, what: Callable) -> Piecewise:
	var end = funcs.back().call(sec)
	times.append(times.back() + sec)
	funcs.append(
		func(t: float) -> Vector4: return end + what.call(t))
	return self

# Gets position exactly at t
func eval(t: float) -> Vector4:
	var i = times.bsearch(t)
	i = min(i, times.size() - 1)
	return funcs[i].call(t - times[i])
