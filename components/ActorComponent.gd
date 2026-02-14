class_name ActorComponent
extends BaseComponent

## Actor uid
var uid:int = -1
var a_button:int = 0
var m_buttorn:int = 0

func _init(_uid:int)->void:
	uid = _uid
	flag = Flag.ACTOR

func clear()->void:
	a_button = 0
	m_buttorn = 0
