class_name VisualSystem
extends BaseSystem

const ANIM_FLAG:VisualComponent.TYPES = VisualComponent.TYPES.ANIMATED

func process()->void:
	_clean_registry()
	_update_positions()
	_update_animation()
## Clear the registry, so the canvas nodes can be deleted
func _clean_registry()->void:
	var uids:Array[int] = REG.get_entities_by(VIS_FLAG).duplicate()  ## Duplicate to avoid mid-loop mutation
	for uid:int in uids:
		var component:VisualComponent = REG.get_component(uid, VIS_FLAG)
		if not component or not component.queue_destroy: continue
		if component.destroy_time > 0:
			component.destroy_time -= REG.DELTA
			continue
		## Time elapsed — safe to destroy
		if is_instance_valid(component.sprite):
			REG.ENT_LAYER.remove_child(component.sprite)
			component.sprite.queue_free()
			component.sprite = null
## Update sprite positions to [MovementComponent]
func _update_positions()->void:
	var uids:Array[int] = REG.get_entities_by(VIS_FLAG | MOV_FLAG)
	
	for uid:int in uids:
		var vis_comp:VisualComponent = REG.get_component(uid, VIS_FLAG)
		if not vis_comp or not vis_comp.sprite: continue
		
		var mov_comp:MovementComponent = REG.get_component(uid, MOV_FLAG)
		if not mov_comp: continue
		vis_comp.sprite.position = mov_comp.position
		if not mov_comp.movable or vis_comp.sprite is ColorRect: continue
		
		vis_comp.sprite.flip_h = not mov_comp.movable.faces_right
## Handle animation state changes
func _update_animation()->void:
	var uids:Array[int] = REG.get_entities_by(VIS_FLAG)
	
	for uid:int in uids:
		var component:VisualComponent = REG.get_component(uid, VIS_FLAG)
		if not component: continue
		if component.type != ANIM_FLAG: continue
		
		var anim_sprite:AnimatedSprite2D = component.sprite
		if not is_instance_valid(anim_sprite): continue
		
		if anim_sprite.animation != component.current_animation:
			if not anim_sprite.sprite_frames.has_animation(component.current_animation): component.current_animation = component.previous_animation
			anim_sprite.play(component.current_animation)
			component.previous_animation = component.current_animation
		
		anim_sprite.speed_scale = component.animation_speed
## Modifies the current animation at [param uid]
func set_animation(uid:int, animation_name:String, )->void:
	var vis_comp:VisualComponent = REG.get_component(uid, VIS_FLAG)
	if not vis_comp or not vis_comp.sprite_type == ANIM_FLAG: return
	
	vis_comp.current_animation = animation_name
