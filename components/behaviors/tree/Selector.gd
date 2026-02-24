## Checks if at least one node succeds.
class_name Selector
extends BTNode
var children:Array[BTNode] = []

func _init(_children:Array[BTNode])->void:
	children = _children
func update(uid:int, blackboard:Dictionary)->Status:
	for child:BTNode in children:
		var status:Status = child.update(uid, blackboard)
		if status != Status.FAILURE: return status
	return Status.FAILURE
