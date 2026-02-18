@tool
class_name FleeBehavior
extends BaseBehavior

func _init()->void:
	behavior_name = "Flee"
	type = Type.FLEE
	active = true
func get_priority(_uid:int)->float:
	if not active: return 0.0
	return priority
func activate(_uid:int)->void: pass
func act(_uid:int)->void: pass
