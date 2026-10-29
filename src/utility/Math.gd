class_name Math

# Solves a 2x2 matrix
func solve_2x2(a: float, b: float, c: float, d: float, x0: float, x1: float) -> Vector2:
	# Find [a b ; c d] * lambda = x. We are finding lambda here
	var det = a * d - b * c
	if is_zero_approx(det):
		# Nope!
		return Vector2.ZERO
	
	var det_x: float = x0 * d - b * x1
	var det_y: float = a * x1 - x0 * c
	return Vector2(det_x / det, det_y / det)

# Gets the closest point of line [a, b] along point p
func closest_point_line(a: Vector2, b: Vector2, p: Vector2) -> Vector2:
	var ab = b - a
	if is_zero_approx(ab):
		return a if a.distance_squared_to(p) < b.distance_squared_to(p) else b

	# dot(a + ab*t, ab) = dot(p, ab)
	# t = dot(p - a, ab) / dot(ab, ab)
	var lambda = clamp((p - a).dot(ab) / ab.dot(ab), 0.0, 1.0)
	return a + ab * lambda

# Gets the closest points of the lines [a, b] and [c, d]
func closest_point_lines(a: Vector2, b: Vector2, c: Vector2, d: Vector2) -> Vector4:
	# a + ab*l_1 = c * cd*l_2
	# a - c = [ab | cd] * [l_1 ; l_2]
	var ab = b - a
	var cd = d - c
	var lambda = solve_2x2(ab.x, cd.x, ab.y, cd.y, a.x - c.x, a.y - c.y)
	
	var root0 = a + ab * clamp(lambda.x, 0.0, 1.0)
	var root1 = c + cd * clamp(lambda.y, 0.0, 1.0)
	return Vector4(root0.x, root0.y, root1.x, root1.y)

# Checks if two capsules (their start/end points in world space) collide.
# Capsule A is a 3-tuple; (a, b, r0), B is a 3-tuple; (c, d, r1)
func do_capsules_collide(a: Vector2, b: Vector2, c: Vector2, d: Vector2, r0: float, r1: float) -> bool:
	var roots = closest_point_lines(a, b, c, d)
	var ct0 = Vector2(roots.x, roots.y)
	var ct1 = Vector2(roots.z, roots.w)
	var r_combined = r0 + r1
	return (ct0 - ct1).length_squared() <= r_combined*r_combined
