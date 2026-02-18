@tool
class_name IdleBehavior
extends BaseBehavior

func _init()->void:
	behavior_name = "Idle"
	type = Type.IDLE

func get_priority()->float:
	if not active: return 0.0
	return priority
func activate(_uid:int)->void: pass
func act(_uid:int)->void: pass
