class_name BTNode
extends BaseComponent

enum Status { SUCCESS, FAILURE, RUNNING }

func update(_uid:int, _blackboard:Dictionary)->Status: return Status.SUCCESS
func abort(_uid:int, _blackboard:Dictionary)->void: pass
