class_name VisualSystem
extends System

## General update (should be only necessary at start)
func instance(world:ECS_MANAGER)->void:
	for entity:Entity in world.get_all_with_component(VisualComponent):
		var visual:VisualComponent = entity.get_component(VisualComponent)
		var movement:MovementComponent = entity.get_component(MovementComponent)
		visual.visual.position = movement.position
func process(world:ECS_MANAGER)->void:
	for entity:Entity in world.get_all_with_component(VisualComponent):
		var visual:VisualComponent = entity.get_component(VisualComponent)
		if not visual: continue
		if visual.is_static: continue
		var movement:MovementComponent = entity.get_component(MovementComponent)
		if visual and movement:
			visual.visual.position = movement.position
