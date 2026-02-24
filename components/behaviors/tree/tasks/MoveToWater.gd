class_name MoveToWater
extends BTNode

func update(uid:int, blackboard:Dictionary)->Status:
	if not blackboard.get("water_pos"): return Status.FAILURE
	
	var target_pos:Vector2 = blackboard["water_pos"]
	var reached:bool = REG.ACT.move_closer(uid, target_pos)
	
	if reached: return Status.SUCCESS
	return Status.RUNNING
