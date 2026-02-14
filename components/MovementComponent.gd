class_name MovementComponent
extends BaseComponent

var position:Vector2 = -Vector2.ONE
## Solid entities block affect pathing (usually of other grounded entities)
var solid:bool = true
## Extends entity for mobility
var movable:Movable = null

## [MoveComponent] constructor
func _init(_position:Vector2, _solid:bool = true, moves:bool = false,
		mov_type:MovementComponent.Movable.Flag = MovementComponent.Movable.Flag.GROUND,
		speed:float = 1.0
	)->void:
	position = _position
	solid = _solid
	if moves:
		movable = MovementComponent.Movable.new()
		movable.speed = speed
		movable.mov_type = mov_type
	flag = Flag.MOVEMENT
## Extension for moving entities' data
class Movable:
	enum Flag {
		AIR,		## Usually, will only collide with other AIR entities or ceiling structures (special tile type)
		GROUND,		## General enitity move type
		PHASE,		## Can only collide with the same type of mov_type entity. Will phase solid blocks (e.g. ghosts)
		UNDER,		## Moves underground, colliding with others of the same [param mov_type]
		WATER }		## Can only collide with other aquatic entities (e.g. fishes)
	var path:Array[Vector2i] = []		## While an entity may move between two points by fractions, the pathing deals with the grid (for solid entities position)
	var speed:float = 1.0
	var mov_type:Flag = Flag.GROUND
	var faces_right:bool = true			## Sprites only face either right or left
	var has_target:bool = false
	func clear()->void:
		path.clear()
		has_target = false
