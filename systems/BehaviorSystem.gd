class_name BehaviorSystem
extends System

var think_interval:int = 60
var counter:int = 0

func process(world:ECS_MANAGER)->void:
	counter += 1
	if counter >= think_interval:
		for entity:Entity in world.get_all_with_component(BehaviorComponent):
			var health:HealthComponent = entity.get_component(HealthComponent)
			if not health: continue
			if health.is_alive:
				think(entity)
		counter = 0
	for entity:Entity in world.get_all_with_component(BehaviorComponent):
		var behavior_comp:BehaviorComponent = entity.get_component(BehaviorComponent)
		if behavior_comp:
			behavior_comp.active_behavior.act(entity, world)
func think(entity:Entity)->void:
	var behavior_comp:BehaviorComponent = entity.get_component(BehaviorComponent)
	if not behavior_comp: return
	
	var health:HealthComponent = entity.get_component(HealthComponent)
	if health and not health.is_alive:
		behavior_comp.active_behavior = null
		return
	
	var TOP_PRIORITY:float = 0.0
	var CHOICE:BehaviorComponent.Behavior = null
	
	for behavior:BehaviorComponent.Behavior in behavior_comp.behaviors:
		var priority:float = behavior.priority(entity)
		if priority > TOP_PRIORITY:
			TOP_PRIORITY = priority
			CHOICE = behavior
	
	if CHOICE and CHOICE != behavior_comp.active_behavior:
		behavior_comp.active_behavior = CHOICE
