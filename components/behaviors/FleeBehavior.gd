class_name FleeBehavior
extends BaseBehavior

func _init()->void:
	behavior_name = "Flee"

func get_priority()->float:
	if not active: return 0.0
	return priority
func act()->void: pass
