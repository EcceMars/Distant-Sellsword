@tool
class_name WanderBehavior
extends BaseBehavior

func _init()->void:
	behavior_name = "Wander"
	type = Type.WANDER

func get_priority()->float:
	if not active: return 0.0
	return priority
func act(uid:int)->void: pass
