## Manager of all actions between behaviors, systems, registries and component needed.
## A reference to it may be found in [member REG.ACT]
class_name ActionSystem
extends BaseSystem

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
