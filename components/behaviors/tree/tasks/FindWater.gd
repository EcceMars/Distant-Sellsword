class_name FindWater
extends BTNode

func update(uid:int, blackboard:Dictionary)->Status:
	var mov_component:MovementComponent = REG.get_component(uid, REG.C_FLAGS.MOVE)
	if not mov_component or not mov_component.movable: return Status.FAILURE
	var water_pos = REG.TE_REG.nearest_of_biome(mov_component.position, TERRAINSTORE.BIOME.WATER)
	if water_pos == -Vector2.ONE:
		blackboard.erase("water_pos")
		return Status.FAILURE
	blackboard["water_pos"] = water_pos
	return Status.SUCCESS
