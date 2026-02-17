## Processes movement of entities
## Handles moving all entities
class_name MovementSystem
extends BaseSystem

enum {
	INVALID,		## For any reason, the entity can't move (e.g. it is process of deletion)
	BLOCKED,		## Movement blocked by obstacle
	FAINTED,		## Movement blocked by state
	FREE			## Normal case
	}

var correcting:Array[MovementComponent] = []
var blocked_positions:Dictionary[Vector2i, Vector2i] = {}

func process()->void:
	var mov_ent_arr:Array[int] = REG.get_entities_by(MOV_FLAG)
	_update_obstacles(mov_ent_arr)
	
	for uid:int in mov_ent_arr:
		var mov_component:MovementComponent = REG.get_component(uid, MOV_FLAG)
		var stats_component:StatsComponent = REG.get_component(uid, STATS_FLAG)
		match (_is_eligible(mov_component, stats_component)):
			INVALID:
				if mov_component.movable: mov_component.movable.clear()
				continue
			BLOCKED:
				mov_component.movable.clear()
				mov_component.movable.path = [mov_component.movable.last_point]
			FAINTED:
				mov_component.movable.path = [mov_component.movable.last_point]
				correcting.append(mov_component)
			FREE:
				correcting.append(mov_component)
	_finish_movement()
## Finishes the movement of [MovementComponent] in [member correcting]
func _finish_movement()->void:
	for mov_comp:MovementComponent in correcting.duplicate():
		if not mov_comp.movable.path:
			correcting.erase(mov_comp)
		var dist:float = _move(mov_comp, true)
		if dist <= 0.0:
			mov_comp.movable.path.pop_front()
			continue
## Actual moving function. [param slide] helps to not change the sprite orientation, while this function is being called with the reason to solely snap the position to grid.
func _move(move_component:MovementComponent, slide:bool = false)->float:
	var movement:MovementComponent.Movable = move_component.movable
	if not movement.path: return 0.0
	var target:Vector2i = movement.path.front()
	if not slide: movement.faces_right = target.x > move_component.position.x
	
	var step:Vector2 = move_component.position.move_toward(target, movement.speed)		# step is Vector2 as to mantain a smooth movement between the path nodes 
	var dist:float = step.distance_to(move_component.position)
	
	move_component.position = step
	movement.last_attempt = move_component.position
	movement.last_point = _world_to_grid(move_component.position)
	return dist
## [param target] expects a [Vector2] for the reason that a mouse's
## click position maybe the one to query it. Remember that all
## points in the path array are converted to [Vector2i].
func force_move(uid:int, target:Vector2, local:bool = false)->bool:
	var mov_component:MovementComponent = _check_movable(REG.get_component(uid, MOV_FLAG))
	if not mov_component: return false
	
	if local:
		target = mov_component.position + target.normalized() * REG.SCALE
	mov_component.movable.path = [_world_to_grid(target)]
	mov_component.movable.faces_right = mov_component.position.x <= target.x
	return true
## Pushes back a point at the end of the [member MovementComponent.Movable.path] array. Remember that all
## points in the path array are converted to [Vector2i].
func queue_move(uid:int, target:Vector2, local:bool = false)->bool:
	var mov_component:MovementComponent = _check_movable(REG.get_component(uid, MOV_FLAG))
	if not mov_component: return false
	
	if local:
		target = mov_component.position + target.normalized() * REG.SCALE
	mov_component.movable.path.append(_world_to_grid(target))
	mov_component.movable.faces_right = mov_component.position.x <= target.x
	return true
## Blocks grid positions where a [member MovementComponent.solid] is located.
func _update_obstacles(mov_ent_arr:Array[int])->void:
	blocked_positions.clear()
	for uid:int in mov_ent_arr:
		var mov_component:MovementComponent = REG.get_component(uid, MOV_FLAG)
		if mov_component.solid:
			var grid_posi:Vector2i = _world_to_grid(mov_component.position)
			blocked_positions[grid_posi] = grid_posi
## A [MovementComponent] is only eligible to move if its [member MovementComponent.Movable] exists and its path is not empty.
## A special case is made if the function recieves a [StatsComponent], where the current state of the entity is also checked.
func _is_eligible(mov_component:MovementComponent, stat_component:StatsComponent = null)->int:
	if not _check_movable(mov_component): return INVALID
	if mov_component.movable.path and blocked_positions.get(mov_component.movable.path.front()):
		if blocked_positions.get(mov_component.movable.path.front()) == mov_component.movable.path.front():
			return INVALID
		return BLOCKED
	if stat_component:
		if not (stat_component.is_conscious and stat_component.is_alive):
			return FAINTED
	#if not mov_component.movable.path: return INVALID
	return FREE
## Requests the [MovementComponent],
## ensuring that such component has the [MovementComponent.Movable] member.
## If not, returns [code]null[/code].
func _check_movable(mov_component:MovementComponent)->MovementComponent:
	if mov_component.movable:
		return mov_component
	return null
## Any point appended to path must be snapped to the grid—as most of the moving input comes from the mouse.
## Then, the movement should be clamped to [REG] parameters.
func _world_to_grid(position:Vector2, blocked:bool = false)->Vector2i:
	var factor:int = (REG.SCALE * (2 if blocked else 1))
	var grid_posi:Vector2i = Vector2i(position).snappedi(factor)
	grid_posi = grid_posi.clamp(Vector2i.ZERO, Vector2i(REG.WIDTH, REG.HEIGHT) * REG.SCALE)
	return grid_posi
