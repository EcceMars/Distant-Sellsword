class_name BTThirsty
extends RefCounted

var root:BTNode

func _init()->void:
	root = Routine.new(
		[
			IsThirsty.new(),
			Selector.new([
				FindWater.new(),
				MoveToWater.new(),
				DrinkWater.new()
			])
		]
	)
func act(uid:int, blackboard:Dictionary)->BTNode.Status:
	if root:
		var status:BTNode.Status = root.update(uid, blackboard)
		return status
	return BTNode.Status.FAILURE
