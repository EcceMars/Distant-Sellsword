@tool
class_name RestBehavior
extends BaseBehavior

func _init()->void:
	behavior_name = "Rest"
	type = Type.REST

func get_priority()->float:
	if not active: return 0.0
	return priority
func activate(_uid:int)->void: pass
func act(uid:int)->void: pass
