## Manager of all actions between behaviors, systems, registries and component needed.
## A reference to it may be found in [member REG.ACT]
class_name ActionSystem
extends BaseSystem

# TODO! Move these to the item description
## How much energy is restored on eating.
const EAT_ENERGY:float = 30.0
## How much hunger is restored on eating.
const EAT_HUNGER:float = 40.0
## How much thirst is restored on eating.
const EAT_THIRST:float = 10.0

## Requests the entity to move to [param target]
func move(uid:int, target:Vector2)->bool:
	var MOV_SYS:MovementSystem = REG.SYSTEMS.get("MovementSystem")
	if not MOV_SYS: return false
	
	return MOV_SYS.add_move(uid, target)
## Scans the entity's vision triangle and updates its [MemoryComponent].
func look(uid:int)->Array[int]:
	var mem:MemoryComponent = REG.get_component(uid, MEM_FLAG)
	if not mem:
		return []

	var found:Array[int] = mem.look(uid, REG.tick)
	return found
## Flips the entity's horizontal facing direction.
func turn_around(uid:int)->void:
	var mov:MovementComponent = REG.get_component(uid, REG.C_FLAGS.MOVE)
	if not mov or not mov.movable: return
	
	mov.movable.faces_right = !mov.movable.faces_right
## Consumes [param food_uid] for [param eater_uid].
## Recovers stats, cleans memory, triggers visual effects and queues destruction.
func eat(eater_uid:int, food_uid:int)->void:
	var stats:StatsComponent = REG.get_component(eater_uid, BaseComponent.Flag.STATS)
	if stats:
		if stats.energy: stats.energy.recover(EAT_ENERGY)
		if stats.hunger: stats.hunger.recover(EAT_HUNGER)
		if stats.thirst: stats.thirst.recover(EAT_THIRST)

	# Forget the entry so memory stays consistent
	var mem:MemoryComponent=REG.get_component(eater_uid, BaseComponent.Flag.MEMORY)
	if mem:
		mem.forget(food_uid)

	# Visual effects + queue destruction
	var food_vis:VisualComponent = REG.get_component(food_uid, REG.C_FLAGS.VISUAL)
	if food_vis:
		_consume_food(food_vis)
## Internal helper for visual consumption of food.
func _consume_food(food_vis:VisualComponent)->void:
	var ANI_SYS:AnimationSystem = REG.SYSTEMS.get("AnimationSystem")
	if ANI_SYS:
		ANI_SYS.shake_sprite(food_vis.sprite)
		ANI_SYS.burst_particles(food_vis.sprite)

	food_vis.destroy_time = 0.5
	food_vis.queue_destroy = true
