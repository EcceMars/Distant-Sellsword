class_name DrinkWater
extends BTNode

func update(uid:int, blackboard:Dictionary)->Status:
	if not blackboard.get("water_pos"): return Status.FAILURE
	
	var drank:bool = REG.ACT.drink(uid)
	if drank:
		blackboard.erase("water_pos")
		return Status.SUCCESS
	return Status.RUNNING
	
