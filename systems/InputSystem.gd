## Handles player input for actor-controlled entities.
class_name InputSystem
extends BaseSystem

const MOVE_THRESHOLD:float = 0.08
const EAT_RADIUS:float = 8.0
var button_delta:float = 0.0

func process()->void:
	var MOV_SYS:MovementSystem = REG.get_system(MovementSystem)
	var acting_entities:Array[int] = REG.get_entities_by(BEHAV_FLAG) 
	for uid:int in acting_entities:
		var movement:MovementComponent = REG.get_component(uid, MOV_FLAG)
		if not MOV_SYS._check_movable(movement): continue
		
		var behav_component:BehaviorComponent = REG.get_component(uid, BEHAV_FLAG)
		if not behav_component.active_behavior or not behav_component.active_behavior is InputBehavior: continue
		
		if Input.is_action_just_pressed("interact"):
			var mov:MovementComponent = REG.get_component(uid, MOV_FLAG)
			if not mov: continue

			if REG.TE_REG.is_water_adjacent(mov.position):
				REG.ACT.drink(uid)

			## Player has no memory — scan IT_REG directly for nearby food.
			for item_uid:int in REG.IT_REG.get_all_items():
				var item:ItemComponent = REG.IT_REG.get_item(item_uid)
				if not item or item.owner_uid != -1: continue

				if mov.position.distance_to(item.world_position) <= EAT_RADIUS:
					
					REG.ACT.eat(uid, item_uid)
					break

		var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
		if input_dir != Vector2.ZERO:
			button_delta = clampf(button_delta + REG.DELTA, 0.0, MOVE_THRESHOLD)
			if button_delta >= MOVE_THRESHOLD:
				MOV_SYS.add_move(uid, input_dir, true)
		else:
			button_delta = 0.0
