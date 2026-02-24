## For a routine, all children nodes must succed.
class_name Routine
extends BTNode

var children:Array[BTNode] = []

func _init(_children:Array[BTNode])->void:
	children = _children
func update(uid:int, blackboard:Dictionary)->Status:
	for child:BTNode in children:
		var status:Status = child.update(uid, blackboard)
		if status != Status.SUCCESS: return status
	return Status.SUCCESS
