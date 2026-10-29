class_name Piecewise

# Represents a piecewise function!!
# The way this works is that you provide it
# some initial position, velocity, acceleration for the main constructor
# However, after that, you can add new positions (this will respect the last calculated position)

# ```gd
# # Go right, and after 0.5 seconds, we would like to spin in a circle!
# var piecewise = Piecewise.new(Vector2.ZERO, Vector2(100, 0), Vector2.ZERO)
# 	.add(0.5, func(t: float) -> Vector2: return 50.0 * Vector2(cos(t), sin(t)))
# ```

# We'll keep these guys separate since GD script doesn't
# have record type >_>
var funcs: Array[Callable] = []
var times: Array[int] = []

func _init(p: Vector2, v: Vector2, a: Vector2):
	times.append(0)
	funcs.append(
		func(t: float) -> Vector2:
			return p + v * t + a * t * t / 2)
	pass

# Adds to the callable list...
func add(sec: float, what: Callable) -> Piecewise:
	var end = funcs.back().call(sec)
	times.append(end + sec)
	funcs.append(
		func(t: float) -> Vector2: return end + what.call(t))
	return self

# Gets position exactly at t
func eval(t: float) -> Vector2:
	var i = times.bsearch(t, true)
	return funcs[i].call(t - times[i])
