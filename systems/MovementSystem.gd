## Processes movement of entities
class_name MovementSystem
extends BaseSystem

const MOV_FRAME_LEN:float = 0.01
var frame:float = 0.0

enum MoveState {
	INVALID,    # Can't move (no movable component)
	BLOCKED,    # Path is blocked
	STOPPED,    # No movement target
	MOVING,     # Actively moving along path
	ARRIVED     # Just reached destination this frame
}

var grid_positions:Dictionary[Vector2i, int] = {}
var blocked_positions:Dictionary[Vector2i, int] = {}

func process()->void:
	if frame < MOV_FRAME_LEN:
		frame += REG.DELTA
		return
	frame = 0.0
	
	var mov_ent_arr:Array[int] = REG.get_entities_by(MOV_FLAG)
	_update_grid_obj(mov_ent_arr)
	
	for uid:int in mov_ent_arr:
		var mov_component:MovementComponent = REG.get_component(uid, MOV_FLAG)
		var stats_component:StatsComponent = REG.get_component(uid, STATS_FLAG)
		
		# Determine and update movement state
		var move_state:MoveState = _get_move_state(uid, mov_component, stats_component)
		_update_movable_state(mov_component, move_state)
		
		# Handle movement based on state
		match move_state:
			MoveState.MOVING:
				_process_movement(mov_component)
			MoveState.BLOCKED, MoveState.INVALID:
				_clear_movement(mov_component)

func _get_move_state(uid:int, mov_component:MovementComponent, stats_component:StatsComponent)->MoveState:
	if not _check_movable(mov_component):
		return MoveState.INVALID
	
	if stats_component and not (stats_component.is_conscious and stats_component.is_alive):
		return MoveState.BLOCKED
	
	var movable:MovementComponent.Movable = mov_component.movable
	
	if movable.path.is_empty():
		movable.has_target = false
		return MoveState.STOPPED
	
	var target_grid:Vector2i = movable.path[0]

	## Check terrain passability before entity blocking
	if not _can_enter_tile(mov_component, target_grid):
		return MoveState.BLOCKED

	if blocked_positions.has(target_grid) and blocked_positions[target_grid] != uid:
		return MoveState.BLOCKED
	
	return MoveState.MOVING

## Returns true if [param mov_component]'s movement type can enter [param grid].
func _can_enter_tile(mov_component:MovementComponent, grid:Vector2i)->bool:
	if not REG.TE_REG: return true
	var world_pos:Vector2 = Vector2(grid)
	return REG.TE_REG.can_spawn(world_pos, mov_component.movable.mov_type)

func _update_movable_state(mov_component:MovementComponent, move_state:MoveState)->void:
	var movable:MovementComponent.Movable = mov_component.movable
	if not movable:
		return
	
	match move_state:
		MoveState.MOVING:
			movable.has_target = true
		MoveState.STOPPED, MoveState.ARRIVED:
			movable.has_target = false
			movable.path.clear()
		# BLOCKED keeps has_target true so animations don't flicker

func _process_movement(mov_component:MovementComponent)->void:
	var movable:MovementComponent.Movable = mov_component.movable
	if movable.path.is_empty():
		return
	
	var target:Vector2i = movable.path[0]
	var current_pos:Vector2 = mov_component.position
	var target_pos:Vector2 = Vector2(target)
	
	# Update facing direction
	var x_diff:float = target_pos.x - current_pos.x
	if not is_zero_approx(x_diff):
		movable.faces_right = x_diff > 0
	
	# Move toward target
	var step:Vector2 = current_pos.move_toward(target_pos, movable.speed)
	mov_component.position = step
	
	# Check if we've reached the waypoint
	if current_pos.distance_to(target_pos) < 0.01:
		movable.path.pop_front()
		movable.last_point = _world_to_grid(mov_component.position)
	mov_component.grid_posi = _world_to_grid(mov_component.position)
func _clear_movement(mov_component:MovementComponent)->void:
	var movable:MovementComponent.Movable = mov_component.movable
	if movable:
		movable.path.clear()
		# Keep last_point for reference
func add_move(uid:int, target:Vector2, local:bool = false)->bool:
	var mov_component:MovementComponent = _check_movable(REG.get_component(uid, MOV_FLAG))
	if not mov_component:
		return false
	
	if local:
		target = mov_component.position + target.normalized() * REG.SCALE
	
	if not blocked_positions.has(_world_to_grid(target)):
		# Clear existing path and set new target
		mov_component.movable.path = [_world_to_grid(target)]
		mov_component.movable.has_target = true
		return true
	return false
func force_move(uid:int, target:Vector2, local:bool = false)->bool:
	var mov_component:MovementComponent = _check_movable(REG.get_component(uid, MOV_FLAG))
	if not mov_component:
		return false
	
	if local:
		target = mov_component.position + target.normalized() * REG.SCALE
	
	# Clear existing path and set new target
	mov_component.movable.path = [_world_to_grid(target)]
	mov_component.movable.has_target = true
	return true

func queue_move(uid:int, target:Vector2, local:bool = false)->bool:
	var mov_component:MovementComponent = _check_movable(REG.get_component(uid, MOV_FLAG))
	if not mov_component:
		return false
	
	if local:
		target = mov_component.position + target.normalized() * REG.SCALE
	
	var grid_target:Vector2i = _world_to_grid(target)
	if blocked_positions.has(grid_target):
		return false
	
	mov_component.movable.path.append(grid_target)
	mov_component.movable.has_target = true
	return true

func _update_grid_obj(mov_ent_arr:Array[int])->void:
	grid_positions.clear()
	blocked_positions.clear()
	for uid:int in mov_ent_arr:
		var mov_component:MovementComponent = REG.get_component(uid, MOV_FLAG)
		if mov_component:
			var grid_posi:Vector2i = mov_component.grid_posi
			grid_positions[grid_posi] = uid
			if mov_component.solid: blocked_positions[grid_posi] = uid
func _check_movable(mov_component:MovementComponent)->MovementComponent:
	if mov_component and mov_component.movable:
		return mov_component
	return null

func _world_to_grid(position:Vector2)->Vector2i:
	var factor:float = REG.SCALE
	var snapped_pos:Vector2 = position.snapped(Vector2(factor, factor))
	return Vector2i(snapped_pos).clamp(
		Vector2i.ZERO, 
		Vector2i(REG.WIDTH -1, REG.HEIGHT -1) * REG.SCALE
	)
