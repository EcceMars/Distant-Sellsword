class_name MovementComponent
extends BaseComponent

var position:Vector2 = Vector2.ZERO
var movable:Movable = null

func _init(_position:Vector2, moves:bool = false, _speed:float = 1.0, _facing:Vector2 = Vector2.RIGHT)->void:
	position = _position
	if moves:
		movable = Movable.new(position, _speed, _facing)
func clear_path()->void:
	if movable:
		movable.target.clear()
		movable.target = [position]
		movable.has_target = false
func _to_string()->String:
	return get_script().get_global_name() + " is " + "movable" if movable else "static"
## Subclass to extend the MovementComponent from a static to a movable entity
class Movable:
	## Movement queue
	var target:Array[Vector2] = []
	var direction:Vector2 = Vector2.RIGHT
	var speed:float = 0.0
	var has_target:bool = false
	
	func _init(ini_position:Vector2, _speed:float, _facing:Vector2 = Vector2.RIGHT)->void:
		target.append(ini_position)
		speed = _speed
		direction = _facing.normalized()
		has_target = false
