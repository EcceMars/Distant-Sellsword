@tool
class_name IdleBehavior
extends BaseBehavior

func _init()->void:
	behavior_name = "Idle"

func get_priority()->float:
	if not active: return 0.0
	return priority
func act()->void: pass
