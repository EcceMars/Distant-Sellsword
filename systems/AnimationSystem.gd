class_name AnimationSystem
extends BaseSystem

const AC_STATE = AnimationStateComponent.State
const STATE:Dictionary = {
	AC_STATE.IDLE: "idle",
	AC_STATE.WALK: "walk",
	AC_STATE.ACT: "act",
	AC_STATE.REST: "rest",
	AC_STATE.ATTACK: "attack",
	AC_STATE.DEATH: "death"
}

func process(REG:REGISTRY)->void:
	for uid:int in REG.get_entities_by(ANIM_STATE_FLAG | VIS_FLAG):
		var anim_state:AnimationStateComponent = REG.get_component(uid, ANIM_STATE_FLAG)
		var vis_comp:VisualComponent = REG.get_component(uid, VIS_FLAG)
		
		if vis_comp.sprite_type != VisualComponent.SpriteType.ANIMATED:
			continue
		
		var mov_comp:MovementComponent = REG.get_component(uid, MOV_FLAG)
		if mov_comp and mov_comp.movable and mov_comp.movable.has_target:
			anim_state.change(AC_STATE.WALK)
		else:
			anim_state.change(AC_STATE.IDLE)
		
		var behavior:BehaviorComponent = REG.get_component(uid, BEHAV_FLAG)
		if behavior:
			match behavior.active_behavior.name:
				"REST": anim_state.change(AC_STATE.REST)
				"MOVE", "SEEK_FOOD": anim_state.change(AC_STATE.WALK)
		
		var anim_name:String = STATE.get(anim_state.current, "idle")
		vis_comp.current_animation = anim_name
		anim_state.latency += 1
