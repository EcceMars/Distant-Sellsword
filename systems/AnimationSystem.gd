class_name AnimationSystem
extends BaseSystem

const AC_STATE = AnimationStateComponent.State
const STATE:Dictionary = {
	AC_STATE.IDLE: "idle",
	AC_STATE.WALK: "walk",
	}
const BEHAV_TYPES = BaseBehavior.Type

func process()->void:
	for uid:int in REG.get_entities_by(ANIM_STATE_FLAG | VIS_FLAG):
		var anim_state:AnimationStateComponent = REG.get_component(uid, ANIM_STATE_FLAG)
		var vis_comp:VisualComponent = REG.get_component(uid, VIS_FLAG)
		
		if not vis_comp or vis_comp.sprite_type != VisualComponent.SpriteType.ANIMATED:
			continue
		
		# Determine desired animation state
		var target_state:AC_STATE = _determine_animation_state(uid)
		
		# Apply the state change (will only change if different)
		anim_state.change(target_state)
		
		# Update visual component
		var anim_name:String = STATE.get(anim_state.current, "idle")
		vis_comp.current_animation = anim_name

func _determine_animation_state(uid:int)->AC_STATE:
	# Priority 1: Check behavior overrides
	var behavior:BehaviorComponent = REG.get_component(uid, BEHAV_FLAG)
	if behavior:
		match behavior.active_behavior.type:
			BEHAV_TYPES.IDLE:
				return AC_STATE.IDLE  # Or create REST state
			BEHAV_TYPES.WANDER, BEHAV_TYPES.REST:
				return AC_STATE.WALK

	# Priority 2: Check movement state
	var mov_comp:MovementComponent = REG.get_component(uid, MOV_FLAG)
	if mov_comp and mov_comp.movable:
		# Use has_target to determine if we should be walking
		if mov_comp.movable.has_target:
			return AC_STATE.WALK
	
	# Default to idle
	return AC_STATE.IDLE
