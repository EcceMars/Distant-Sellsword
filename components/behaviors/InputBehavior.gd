@tool
class_name InputBehavior
extends BaseBehavior

func _init()->void:
	behavior_name = "Input"
	type = Type.INPUT

func get_priority()->float:
	if not active: return 0.0
	return priority
func act(_uid:int)->void: pass
