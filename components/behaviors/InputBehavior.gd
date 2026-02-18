@tool
class_name InputBehavior
extends BaseBehavior

func _init()->void:
	behavior_name = "Input"
	type = Type.INPUT
	active = true
func get_priority(_uid:int)->float:
	if not active: return 0.0
	return priority
func activate(_uid:int)->void: pass
func act(_uid:int)->void: pass
