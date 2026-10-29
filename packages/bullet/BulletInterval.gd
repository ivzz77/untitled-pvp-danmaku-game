class_name BulletInterval

# Structure to hold the interval data. I did it this way
# so we don't have to create a dictionary every single time
# we request a BulletInterval LOL

var piecewise: Piecewise
var center: float
var kind: String
var start: float
var end: float

func _init(kind: String, start: float, end: float, piecewise: Piecewise) -> void:
	self.piecewise = piecewise
	self.center = (start + end) * 0.5
	self.start = start
	self.kind = kind
	self.end = end
