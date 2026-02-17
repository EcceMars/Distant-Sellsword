## Handles player input for actor-controlled entities.
class_name ActorSystem
extends BaseSystem

const MOVE_THRESHOLD:float = 0.08
var button_delta:float = 0.0

func process()->void:
	var MOV_SYS:MovementSystem = REG.SYSTEMS.get("MovementSystem")
	for actor:ActorComponent in REG.get_all_components_of(ACTOR_FLAG):
		var movement:MovementComponent = REG.get_component(actor.uid, MOV_FLAG)
		
		if not MOV_SYS._check_movable(movement): continue
		
		var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
		if input_dir != Vector2.ZERO:
			button_delta = clampf(button_delta + REG.DELTA, 0.0, MOVE_THRESHOLD)
			if button_delta >= MOVE_THRESHOLD:
				MOV_SYS.add_move(actor.uid, input_dir, true)
		else:
			button_delta = 0.0
