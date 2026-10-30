# This interval array assumes that our queries keep on going forward
# and is incrementally built as the game progresses. This can also be
# repurposed for the charting system if necessary
# magical

class_name IntervalArray

const ROLLBACK_ALLOW_TIME = 1.0

class HeapNode:
	var key: int
	var value: int
	
	func _init(_key: int, _value: int) -> void:
		value = _value
		key = _key

var _active: Dictionary[int, bool] = {}
var _pending: Array[HeapNode] = []
var _ending: Array[HeapNode] = []
var _freelist: Array[int] = []

var _data: Array[Variant] = []
var _start: Array[float] = []

# Helper function to insert n into what, assuming a min-heap
static func heap_push(what: Array[HeapNode], n: HeapNode) -> void:
	what.push_back(n)
	
	# Keep on checking the parent until there is
	# no heap violation
	var id = what.size() - 1
	while id != 0:
		var parent = (id - 1) >> 1
		if what[parent].key > what[id].key:
			# Heap violation! Swap parent and child
			var temp = what[id]
			what[id] = what[parent]
			what[parent] = temp
			id = parent
		else:
			break

# Helper function to remove the smallest element from the min-heap
static func heap_pop(what: Array[HeapNode]) -> HeapNode:
	if what.size() == 1:
		return what.pop_back()

	var popped = what[0]
	what[0] = what.pop_back()
	
	var id = 0
	while (id << 1) + 1 < what.size():
		# Check the largest sibling to compare
		# against heap violation
		var sibling = (id << 1) + 1
		var right = sibling + 1
		
		if what.size() > right and what[sibling].key > what[right].key:
			sibling = right
		
		if what[sibling].key < what[id].key:
			# Heap violation!
			var temp = what[id]
			what[id] = what[sibling]
			what[sibling] = temp
			id = sibling
		else:
			break
	
	return popped

# Inserts a new event in O(lgn) time
func insert(a: float, b: float, value: Variant) -> int:
	var id = 0
	if _freelist.is_empty():
		id = _data.size()
		_start.push_back(a)
		_data.push_back(value)
	else:
		id = _freelist.pop_back()
		_start[id] = a
		_data[id] = value
	
	if _active.has(id):
		_active.erase(id)
	
	heap_push(_pending, HeapNode.new(a, id))
	heap_push(_ending, HeapNode.new(b, id))
	return id

# Deletes the given key from the interval array if it failed
func delete(key: int) -> void:
	_data[key] = null
	if _active.has(key):
		_active.erase(key)

# Checks all current events at time t. Assumes that t_prev - t <= ROLLBACK_TIME
func advance(t: float) -> Array[Variant]:
	# See if we can insert any events to the active set
	while _pending.size() != 0 and _pending[0].key <= t:
		var popped = heap_pop(_pending)
		if _data[popped.value] != null:
			_active[popped.value] = true
	
	# Check if we can remove any events from the active set
	while _ending.size() != 0 and _ending[0].key <= t - ROLLBACK_ALLOW_TIME:
		var popped = heap_pop(_ending)
		_freelist.append(popped.value)
		_active.erase(popped.value)
	
	var result = []
	for key in _active.keys():
		# Since we did allow some leeway with rollback time
		if _start[key] <= t:
			result.append(_data[key])
	
	return result
