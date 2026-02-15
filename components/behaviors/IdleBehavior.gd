## Idle behavior - fallback when nothing else to do.
## Always has low priority, acts as a safety net.
@tool
class_name IdleBehavior
extends Behavior

## Priority (constant, should be lowest)
@export_range(0.0, 0.5, 0.05) var base_priority:float = 0.1

func _init()->void:
	behavior_name = "Idle"
	description = "Fallback behavior when nothing else to do"
	enabled = true

func priority(_uid:int, _REG:REGISTRY)->float:
	if not enabled:
		return 0.0
	
	return base_priority

func act(_uid:int, _REG:REGISTRY)->void: pass
