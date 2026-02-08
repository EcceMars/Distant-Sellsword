class_name BehaviorSystem
extends System

func process(world:ECS_MANAGER)->void:
	for entity:Entity in world.get_all_with_component(BehaviorComponent):
		var behavior:BehaviorComponent = entity.get_component(BehaviorComponent)
		var health:HealthComponent = entity.get_component(HealthComponent)
		
		if health.blood.ratio() < behavior.dying:
			behavior.current = BehaviorComponent.State.FLEE
		elif health.energy.ratio() < behavior.tired:
			behavior.current = BehaviorComponent.State.REST
		elif health.hunger.ratio() < behavior.hungry:
			behavior.current = BehaviorComponent.State.SEEK_FOOD
