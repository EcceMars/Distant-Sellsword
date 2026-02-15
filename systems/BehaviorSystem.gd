class_name BehaviorSystem
extends BaseSystem

## How often to re-evaluate behavior priorities (in frames)
var think_interval:int = 6
var counter:int = 0

func process(REG:REGISTRY)->void:
	counter += 1
	
	# Periodically re-evaluate priorities
	if counter >= think_interval:
		for uid:int in REG.get_entities_by(BEHAV_FLAG):
			var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
			if not stats:
				continue
			if stats.is_alive:
				_think(uid, REG)
		counter = 0
	
	# Execute active behaviors every frame
	for uid:int in REG.get_entities_by(BEHAV_FLAG):
		var behavior_comp:BehaviorComponent = REG.get_component(uid, BEHAV_FLAG)
		if behavior_comp and behavior_comp.active_behavior:
			behavior_comp.active_behavior.act(uid, REG)

## Evaluates all behaviors and switches to highest priority
func _think(uid:int, REG:REGISTRY)->void:
	var behav_comp:BehaviorComponent = REG.get_component(uid, BEHAV_FLAG)
	if not behav_comp:
		return
	
	var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
	if stats and not stats.is_alive:
		behav_comp.active_behavior = null
		return
	
	var top_priority:float = 0.0
	var choice:Behavior = null
	
	# Evaluate all behaviors
	for behavior:Behavior in behav_comp.behaviors:
		var priority:float = behavior.priority(uid, REG)
		if priority > top_priority:
			top_priority = priority
			choice = behavior
	
	# Switch behavior if changed
	if choice and choice != behav_comp.active_behavior:
		_switch_behavior(uid, behav_comp, choice, REG)

## Handles behavior transitions with on_enter/on_exit callbacks
func _switch_behavior(uid:int, behav_comp:BehaviorComponent, new_behavior:Behavior, REG:REGISTRY)->void:
	# Call on_exit for old behavior
	if behav_comp.active_behavior:
		behav_comp.active_behavior.on_exit(uid, REG)
	
	# Switch
	behav_comp.active_behavior = new_behavior
	
	# Call on_enter for new behavior
	if new_behavior:
		new_behavior.on_enter(uid, REG)
