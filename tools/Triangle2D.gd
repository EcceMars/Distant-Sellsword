## Lightweight triangle primitive for 2D spatial queries.
## Used primarily for entity vision arcs.
class_name Triangle2D
extends RefCounted

var a:Vector2	## Tip — furthest forward point
var b:Vector2	## Base left
var c:Vector2	## Base right

var _bounds:Rect2

func _init(_a: Vector2, _b: Vector2, _c: Vector2) -> void:
	a = _a
	b = _b
	c = _c
	_bounds = _compute_bounds()
## Returns true if [param point] lies inside or on the triangle edge.
## Uses sign-of-cross-product method — no trig, three cross products.
func has_point(point: Vector2) -> bool:
	if not _bounds.has_point(point):
		return false
	return _same_side(point, a, b, c) \
		and _same_side(point, b, a, c) \
		and _same_side(point, c, a, b)
## Builds a vision triangle from an entity's world state.
## [param origin]		entity position (centroid anchor)
## [param faces_right]	sprite facing direction
## [param length]		how far the vision reaches forward (in world units)
## [param half_width]	half-width of the base (lateral spread)
## [param back_ratio]	how far behind origin the base sits [0.0–1.0]
static func from_facing(
	origin: Vector2,
	faces_right: bool,
	length: float,
	half_width: float,
	back_ratio: float = 0.2) -> Triangle2D:

	var forward: Vector2 = Vector2.RIGHT if faces_right else Vector2.LEFT
	var perp: Vector2    = Vector2(forward.y, -forward.x)	## 90° rotation, no trig

	var tip: Vector2   = origin + forward * length
	var base: Vector2  = origin - forward * (length * back_ratio)
	var left: Vector2  = base + perp * half_width
	var right: Vector2 = base - perp * half_width

	return Triangle2D.new(tip, left, right)
## Returns the axis-aligned bounding box of the triangle.
func get_bounds() -> Rect2:
	return _bounds

func _compute_bounds() -> Rect2:
	var min_x: float = minf(a.x, minf(b.x, c.x))
	var min_y: float = minf(a.y, minf(b.y, c.y))
	var max_x: float = maxf(a.x, maxf(b.x, c.x))
	var max_y: float = maxf(a.y, maxf(b.y, c.y))
	return Rect2(Vector2(min_x, min_y), Vector2(max_x - min_x, max_y - min_y))

## Returns true if [param p] and [param a] are on the same side of line [param b]→[param c].
func _same_side(p: Vector2, _a: Vector2, _b: Vector2, _c: Vector2) -> bool:
	var cp1: float = (_c - _b).cross(p  - _b)
	var cp2: float = (_c - _b).cross(_a - _b)
	return cp1 * cp2 >= 0.0
