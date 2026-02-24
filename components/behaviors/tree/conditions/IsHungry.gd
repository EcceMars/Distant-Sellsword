class_name IsHungry
extends BTNode

func update(uid:int, _blackboard:Dictionary)->Status:
	var stat_component:StatsComponent = REG.get_component(uid, REG.C_FLAGS.STATS)
	if not stat_component or not stat_component.hunger: return Status.FAILURE
	if stat_component.hunger.ratio() < 0.5: return Status.SUCCESS
	return Status.FAILURE
