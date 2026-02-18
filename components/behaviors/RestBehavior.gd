@tool
class_name RestBehavior
extends BaseBehavior

func _init()->void:
	behavior_name = "Rest"
	type = Type.REST
	active = true
func get_priority(_uid:int)->float:
	if not active: return 0.0
	return priority
func activate(_uid:int)->void: pass
func act(_uid:int)->void: pass
