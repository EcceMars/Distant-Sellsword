## Negates a [BTNode]
class_name Inverter
extends BTNode
var child:BTNode
func _init(_child:BTNode)->void: child = _child
func update(uid:int, blackboard:Dictionary)->Status:
	var status:Status = child.update(uid, blackboard)
	if status == Status.RUNNING: return status
	return Status.SUCCESS if status == Status.FAILURE else status
