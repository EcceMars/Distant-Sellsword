class_name BehaviorSystem
extends BaseSystem

var think_interval:int = 6
var counter:int = think_interval

func process(REG:REGISTRY)->void:
	counter += 1
	if counter >= think_interval:
		for uid:int in REG.get_entities_by(BEHAV_FLAG):
			var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
			if not stats: continue
			if stats.is_alive:
				think(uid, REG)
		counter = 0
	for uid:int in REG.get_entities_by(BEHAV_FLAG):
		var behavior_comp:BehaviorComponent = REG.get_component(uid, BEHAV_FLAG)
		if behavior_comp:
			behavior_comp.active_behavior.act(uid, REG)
func think(uid:int, REG:REGISTRY)->void:
	var behav_comp:BehaviorComponent = REG.get_component(uid, BEHAV_FLAG)
	if not behav_comp: return
	
	var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
	if stats and not stats.is_alive:
		behav_comp.active_behavior = null
		return
	
	var TOP_PRIORITY:float = 0.0
	var CHOICE:BehaviorComponent.Behavior = null
	
	for behavior:BehaviorComponent.Behavior in behav_comp.behaviors:
		var priority:float = behavior.priority(uid, REG)
		if priority > TOP_PRIORITY:
			TOP_PRIORITY = priority
			CHOICE = behavior
	
	if CHOICE and CHOICE != behav_comp.active_behavior:
		behav_comp.active_behavior = CHOICE
