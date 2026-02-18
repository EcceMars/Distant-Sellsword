## Should run after [MovementSystem] so grid_positions is always fresh.
class_name BehaviorSystem
extends BaseSystem

## How many ticks between perception updates, keyed by behavior type.
## Entities with no memory, or with INPUT behavior, skip perception entirely.
const PERCEPTION_INTERVALS:Dictionary = {
	BaseBehavior.Type.REST:		40,
	BaseBehavior.Type.IDLE:		20,
	BaseBehavior.Type.WANDER:	10,
	BaseBehavior.Type.FLEE:		2,
	}

const MEMORY_FLAG:	BaseComponent.Flag = BaseComponent.Flag.MEMORY
const ITEM_FLAG:	BaseComponent.Flag = BaseComponent.Flag.ITEM

func process() -> void:
	var entities:Array[int] = REG.get_entities_by(BEHAV_FLAG)
	for uid:int in entities:
		var behav:BehaviorComponent = REG.get_component(uid, BEHAV_FLAG)
		if not behav:
			continue

		## Skip player-controlled entities — InputSystem handles them
		if behav.active_behavior is InputBehavior:
			continue

		_update_perception(uid, behav)
		_activate_all(uid, behav)
		_select_behavior(behav)
		behav.active_behavior.act(uid)
## Calls [method BaseBehavior.activate] on every behavior the entity owns,
## so each can update its priority before [method _select_behavior] runs.
## Only [SeekFoodBehavior] (and future dynamic behaviors) implement this;
## the base no-op is safe for all others.
func _activate_all(uid:int, behav:BehaviorComponent)->void:
	for b:BaseBehavior in behav.behaviors.values():
		if b and b.has_method("activate"):
			b.activate(uid)
## Rebuilds the vision triangle and records newly visible entities into memory.
## Skips if not enough ticks have elapsed since the last update.
func _update_perception(uid:int, behav:BehaviorComponent) -> void:
	var mem:MemoryComponent = REG.get_component(uid, MEMORY_FLAG)
	if not mem:
		return

	var interval:int = PERCEPTION_INTERVALS.get(
		behav.active_behavior.type,
		PERCEPTION_INTERVALS[BaseBehavior.Type.IDLE])

	if REG.tick - mem.last_update_tick < interval:
		return

	mem.last_update_tick = REG.tick

	var mov:MovementComponent = REG.get_component(uid, MOV_FLAG)
	if not mov:
		return

	var triangle:Triangle2D = mem.build_vision_triangle(mov)

	## Iterate grid_positions — already computed this frame by MovementSystem
	var mov_sys:MovementSystem = REG.SYSTEMS.get("MovementSystem")
	if not mov_sys:
		return

	for grid_pos:Vector2i in mov_sys.grid_positions:
		var candidate_uid:int = mov_sys.grid_positions[grid_pos]
		if candidate_uid == uid:
			continue

		var world_pos:Vector2 = Vector2(grid_pos)
		if not triangle.has_point(world_pos):
			continue

		var relation:MemoryComponent.Relation = _classify(candidate_uid)
		mem.remember(candidate_uid, relation, world_pos, REG.tick)
## Classifies a candidate entity into a [enum MemoryComponent.Relation].
## Items are FOOD; everything else starts as NEUTRAL.
func _classify(candidate_uid:int)->MemoryComponent.Relation:
	if REG.has_components(candidate_uid, ITEM_FLAG):
		return MemoryComponent.Relation.FOOD
	return MemoryComponent.Relation.NEUTRAL
## Selects the highest-priority behavior and swaps if it has changed.
func _select_behavior(behav:BehaviorComponent)->void:
	var best:BaseBehavior = null
	var best_priority:float = -1.0

	for type:BaseBehavior.Type in behav.behaviors:
		var candidate:BaseBehavior = behav.behaviors[type]
		if not candidate: continue
		var p:float = candidate.get_priority()
		if p > best_priority:
			best_priority = p
			best = candidate

	if not best or best == behav.active_behavior:
		return

	behav.active_behavior.on_exit()
	behav.active_behavior = best
	behav.active_behavior.on_enter()
