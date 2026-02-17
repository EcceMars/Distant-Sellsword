## Data component for player input.
class_name ActorComponent
extends BaseComponent

## Actor uid
var uid:int = -1

func _init(_uid:int)->void:
	uid = _uid
	flag = Flag.ACTOR
