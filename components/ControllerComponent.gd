class_name ControllerComponent
extends BaseComponent

var monitor:Node = null
var entity:Entity = null
var cmp:MovementComponent = null
var sys:MovementSystem = null
var m_button:int = 0
var a_button:int = 0
var axis:Vector2 = Vector2.ZERO

func _init(anchor:Node, _entity:Entity)->void:
	monitor = anchor
	entity = _entity
	cmp = entity.get_component(MovementComponent)
