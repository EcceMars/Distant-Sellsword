class_name MovementSystem
extends System

## Forces the target queue to update (for player control movement, for example)
func force_move(entity:Entity, target:Vector2)->void:
	var movement:MovementComponent = entity.get_component(MovementComponent)
	if movement and movement.movable:
		movement.movable.target.clear()
		movement.movable.target = [movement.position]
		movement.movable.target = [target]
## Queue a position node to the target queue
func queue_move(entity:Entity, target:Vector2)->void:
	var movement:MovementComponent = entity.get_component(MovementComponent)
	if movement and movement.movable:
		movement.movable.target.append(target)
## Moves the entity towards its target
func move_towards(component:MovementComponent)->void:
	component.position = component.position.move_toward(component.movable.target.front(), component.movable.speed)
	check_queue(component)
func check_queue(component:MovementComponent)->void:
	var move_queue:Array = component.movable.target
	if component.movable.target.front() == component.position:
		move_queue.pop_front()
		if move_queue.is_empty():
			move_queue.append(component.position)
func process(world:ECS_MANAGER)->void:
	for entity:Entity in world.get_all_with_component(MovementComponent):
		var movement:MovementComponent = entity.get_component(MovementComponent)
		if not movement.movable: continue
		if not movement.movable.has_target: continue
		move_towards(movement)
