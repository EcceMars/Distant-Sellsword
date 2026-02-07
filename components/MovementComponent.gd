class_name MovementComponent
extends BaseComponent

var position:Vector2 = Vector2.ZERO
var movable:Movable = null

func _init(_position:Vector2, moves:bool = false, _speed:float = 1.0, _facing:Vector2 = Vector2.RIGHT)->void:
	position = _position
	if moves:
		movable = Movable.new(position, _speed, _facing)
## Subclass to extend the MovementComponent from a static to a movable entity
class Movable:
	## Movement queue
	var target:Array[Vector2]:
		set(value):
			if not target:
				target = value
			if value.back() == target.back():
				return
			has_target = not target.is_empty() # Will be true as long as it is not the first insertion (initialization) or the target is not equal as the last position
			target.append(value.front())
			print(target)
	var direction:Vector2 = Vector2.RIGHT
	var speed:float = 0.0
	var has_target:bool = false
	
	func _init(ini_position:Vector2, _speed:float, _facing:Vector2 = Vector2.RIGHT)->void:
		target = [ini_position]
		speed = _speed
		direction = _facing.normalized()
		has_target = false
