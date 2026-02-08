class_name MovementSystem
extends System

## Clears the movement queue and force update the target
func force_move(entity:Entity, target:Vector2)->void:
	var movement:MovementComponent = entity.get_component(MovementComponent)
	if movement and movement.movable:
		movement.movable.target.clear()
		movement.movable.target.append(target)
		movement.movable.has_target = movement.movable.target.front() != movement.position
## Queue a position node to the target queue
func queue_move(entity:Entity, target:Vector2)->void:
	var movement:MovementComponent = entity.get_component(MovementComponent)
	if movement and movement.movable:
		movement.movable.target.append(target)
		check_move(movement)
## Moves the entity towards its target
func move_towards(component:MovementComponent)->float:
	var will_move:Vector2 = component.position.move_toward(component.movable.target.front(), component.movable.speed)
	var dist:float = component.position.distance_to(will_move)
	component.position = will_move
	check_move(component)
	return dist
func check_move(component:MovementComponent, stop:bool = false)->void:
	if stop:
		component.movable.target = [component.position]
		return
	var move_queue:Array = component.movable.target
	if move_queue.front() == component.position:
		move_queue.pop_front()
		if move_queue.is_empty():
			move_queue.append(component.position)
			component.movable.has_target = false
	if not move_queue.is_empty():
		component.movable.has_target = true
func process(world:ECS_MANAGER)->void:
	for entity:Entity in world.get_all_with_component(MovementComponent):
		var movement:MovementComponent = entity.get_component(MovementComponent)
		if not movement or not movement.movable: continue
		if not movement.movable.has_target: continue
		var dist:float = 0.0
		var health:HealthComponent = entity.get_component(HealthComponent)
		if health:
			if health.energy.is_depleted(): continue
			dist = move_towards(movement)
			health.energy.hurt(dist)
			check_move(movement, health.energy.is_depleted())
		else:
			move_towards(movement)
		
