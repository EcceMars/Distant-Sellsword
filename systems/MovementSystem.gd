## Processes movement of entities
class_name MovementSystem
extends BaseSystem

func process(REG:REGISTRY)->void:
	for uid:int in REG.get_entities_by(MOV_FLAG):
		var mov_component:MovementComponent = REG.get_component(uid, MOV_FLAG)
		if not _is_eligible(mov_component): continue
		var dist:float = move(mov_component)
		var stats_component:StatsComponent = REG.get_component(uid, STATS_FLAG)
		if stats_component:
			if stats_component.energy.is_depleted(): continue
			stats_component.energy.hurt(dist)
		check_move(mov_component, stats_component.energy.is_depleted())
func move(mov_component:MovementComponent)->float:
	var movement:MovementComponent.Movable = mov_component.movable
	var target:Vector2 = Vector2(movement.path.front())
	movement.faces_right = mov_component.position.x < target.x
	var new_pos:Vector2 = mov_component.position.move_toward(target, movement.speed)
	var dist:float = new_pos.distance_to(mov_component.position)
	mov_component.position = new_pos
	if mov_component.position == target: movement.path.pop_front()
	movement.has_target = not movement.path.is_empty()
	return dist
func check_move(component:MovementComponent, stop:bool = false)->void:
	if stop:
		component.movable.clear()
		return
	var move_queue:Array = component.movable.path
	if not move_queue: return
	if move_queue.front() == Vector2i(component.position.floor()):
		move_queue.pop_front()
	component.movable.has_target = not move_queue.is_empty()
## A [MovementComponent] is only eligible to move if its [MovementComponent.Movable] exists, has a target and its path is not empty
func _is_eligible(mov_component)->bool:
	if not mov_component is MovementComponent: return false
	if not mov_component.movable: return false
	if not mov_component.movable.has_target: return false
	if not mov_component.movable.path: mov_component.movable.has_target = false; return false
	return true
## [param target] expects a [Vector2] for the reason that a mouse's click position maybe the one to query it
func force_move(uid:int, target:Vector2, REG:REGISTRY)->bool:
	var mov_component:MovementComponent = _check_mov_component(REG.get_component(uid, MOV_FLAG), true)
	if not mov_component: return false
	
	mov_component.movable.path.clear()
	mov_component.movable.path = [Vector2i(target)]
	mov_component.movable.has_target = true
	mov_component.movable.faces_right = mov_component.position.x <= target.x
	return true
## Pushes back a point at the end of the [MovementComponent.Movable.path] array. Remember that all
## points in the path array are converted to [Vector2i].
func queue_move(uid:int, target:Vector2, REG:REGISTRY)->bool:
	var mov_component:MovementComponent = _check_mov_component(REG.get_component(uid, MOV_FLAG), true)
	if not mov_component: return false
	
	mov_component.movable.path.append(Vector2i(target))
	mov_component.movable.has_target = true
	mov_component.movable.faces_right = mov_component.position.x <= target.x
	return true
## Requests the [MovementComponent] of an entity with [param uid], while [param must_move]
## ensures that the component has the [MovementComponent.Movable] member.
## If not, returns [code]null[/code].
func _check_mov_component(mov_component:MovementComponent, must_move:bool = false)->MovementComponent:
	if must_move:
		var moves:bool = is_instance_valid(mov_component.movable)
		return mov_component if moves else null
	return mov_component
