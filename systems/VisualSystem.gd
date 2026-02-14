class_name VisualSystem
extends BaseSystem

const ANIM_FLAG:VisualComponent.SpriteType = VisualComponent.SpriteType.ANIMATED

func process(REG:REGISTRY)->void:
	_clean_registry(REG)
	_update_positions(REG)
	_update_animation(REG)
## Clear the registry, so the canvas nodes can be deleted
func _clean_registry(REG:REGISTRY)->void:
	var uids:Array[int] = REG.get_entities_by(VIS_FLAG)
	
	for uid:int in uids:
		var component:VisualComponent = REG.COMPONENT_STORE[uid][VIS_FLAG]
		if component.queue_destroy:
			component.sprite.queue_free()
			REG.visual_nodes.erase(component.sprite)
			REG.delete_component(uid, VIS_FLAG)
## Update sprite positions to [MovementComponent]
func _update_positions(REG:REGISTRY)->void:
	var uids:Array[int] = REG.get_entities_by(VIS_FLAG | MOV_FLAG)
	
	for uid:int in uids:
		var vis_comp:VisualComponent = REG.COMPONENT_STORE[uid][VIS_FLAG]
		if vis_comp.flag == VisualComponent.SpriteType.STATIC: continue
		
		var mov_comp:MovementComponent = REG.COMPONENT_STORE[uid][MOV_FLAG]
		vis_comp.sprite.position = mov_comp.position
		if not mov_comp.movable or vis_comp.sprite is ColorRect: continue
		
		vis_comp.sprite.flip_h = not mov_comp.movable.faces_right
## Handle animation state changes
func _update_animation(REG:REGISTRY)->void:
	var uids:Array[int] = REG.get_entities_by(VIS_FLAG)
	
	for uid:int in uids:
		var component:VisualComponent = REG.COMPONENT_STORE[uid][VIS_FLAG]
		if component.sprite_type != ANIM_FLAG: continue
		
		var anim_sprite:AnimatedSprite2D = component.sprite as AnimatedSprite2D
		if not is_instance_valid(anim_sprite): continue
		
		if anim_sprite.animation != component.current_animation:
			anim_sprite.play(component.current_animation)
		
		anim_sprite.speed_scale = component.animation_speed
## Modifies the current animation at [param uid]
func set_animaiton(uid:int, animation_name:String, REG:REGISTRY)->void:
	var vis_comp:VisualComponent = REG.COMPONENT_STORE[uid].get(VIS_FLAG)
	if not vis_comp or not vis_comp.sprite_type == ANIM_FLAG: return
	
	vis_comp.current_animation = animation_name
