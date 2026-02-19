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
## Shakes [param sprite] for a short time to simulate consumption.
## Uses sequential tweens so the shake animation is actually visible.
func shake_sprite(sprite:Node2D, duration:float = 0.25, intensity:float = 5.0)->void:
	if not sprite or not sprite.is_inside_tree(): return
	
	var original_position:Vector2 = sprite.position
	var tween:Tween = REG.CANVAS.create_tween()
	
	var step_time:float = 0.05
	var steps:int = int(duration/step_time)
	
	for i:int in steps:
		var offset:Vector2 = Vector2(
			randf_range(-intensity, intensity),
			0.0
		)
		tween.tween_property(sprite, "position", original_position+offset,step_time)
	
	# Smooth return to original position
	tween.tween_property(sprite, "position", original_position,0.08)
func burst_particles(sprite:Node2D, color:Color = Color.RED, amount:int = 8) -> void:
	if not sprite or not sprite.is_inside_tree() or not sprite.position: return
	
	# Create a temporary particles node
	var particles:GPUParticles2D = GPUParticles2D.new()
	
	# Create a simple particle material
	var material:ParticleProcessMaterial = ParticleProcessMaterial.new()
	material.color = color
	material.direction = Vector3.UP * -1  # Spread upward
	material.spread = 180.0  # Spread in all directions
	material.gravity = Vector3(0, 200, 0)  # Slight downward gravity
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	material.scale_min = 0.5
	material.scale_max = 1.5
	
	# Configure the particles node
	particles.process_material = material
	particles.amount = amount
	particles.explosiveness = 1.0  # Burst all at once
	particles.one_shot = true
	particles.lifetime = 0.8
	
	# Set position to the visual component's location
	if sprite:
		particles.position = sprite.position + Vector2(8, 8)  # Center of 16x16 sprite
	else:
		particles.position = Vector2(16, 16)  # Default position
	
	# Add to scene and emit
	REG.CANVAS.add_child(particles)
	particles.emitting = true
	
	# Clean up when done
	await REG.CANVAS.get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()
