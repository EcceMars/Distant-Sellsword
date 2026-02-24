## Manages camera movement, panning, edge scrolling, and cinematic functions.
@icon("editor/icons/Camera2D.svg")
class_name CAMERA_MANAGER
extends Node2D

## Reference to the Camera2D node
@export var camera:Camera2D = null
## Current target position for smooth movement
var target_position:Vector2 = Vector2.ZERO

const CLICK_AREA:float = 1.2
## Camera movement speed
const BASE_SPEED:float = 4.0
## Acceleration for smooth movement
var acceleration:float = 0.0
## Edge scroll settings
const EDGE_SCROLL_MARGIN:float = 32.0
const EDGE_SCROLL_SPEED:float = 200.0
@export var permit_edge_scrool:bool = false

## Pan settings
@export var is_panning:bool = false
var pan_start_pos:Vector2 = Vector2.ZERO
var pan_start_cam_pos:Vector2 = Vector2.ZERO

## Follow settings
@export var follow_uid:int = -1
var follow_enabled:bool = false

## World bounds
var world_min:Vector2 = Vector2.ZERO
var world_max:Vector2 = Vector2.ZERO

## Zoom limits
const MIN_ZOOM:float = 0.1
const MAX_ZOOM:float = 3.0
const ZOOM_STEP:float = 0.1

func start(target:Vector2 = target_position)->void:
	world_max = Vector2(REG.WIDTH, REG.HEIGHT) * REG.SCALE
	target_position = Vector2(REG.WIDTH * 0.5, REG.HEIGHT * 0.5) * REG.SCALE
	target_position = target
	position = target_position

## Main update function - call from _process
func process(delta:float)->void:
	_handle_zoom_input()
	_handle_pan_input()
	_handle_edge_scroll(delta)
	_handle_follow()
	_handle_quick_follow()
	_handle_click_search_display()
	_smooth_move_to_target()

## Handle mouse wheel zoom
func _handle_zoom_input()->void:
	if Input.is_action_just_released("wheel_down"):
		camera.zoom = (camera.zoom - Vector2.ONE * ZOOM_STEP).clamp(
			Vector2.ONE * MIN_ZOOM, 
			Vector2.ONE * MAX_ZOOM
		)
	
	if Input.is_action_just_released("wheel_up"):
		camera.zoom = (camera.zoom + Vector2.ONE * ZOOM_STEP).clamp(
			Vector2.ONE * MIN_ZOOM, 
			Vector2.ONE * MAX_ZOOM
		)

## Handle middle mouse button panning
func _handle_pan_input()->void:
	if Input.is_action_just_pressed("pan_camera"):
		is_panning = true
		pan_start_pos = camera.get_viewport().get_mouse_position()
		pan_start_cam_pos = position
		follow_enabled = false
	
	if Input.is_action_just_released("pan_camera"):
		is_panning = false
	
	if is_panning:
		var current_mouse:Vector2 = camera.get_viewport().get_mouse_position()
		var delta_mouse:Vector2 = pan_start_pos - current_mouse
		target_position = _clamp_position(pan_start_cam_pos + delta_mouse / camera.zoom.x)

## Handle edge scrolling when mouse is near viewport edges
func _handle_edge_scroll(delta:float)->void:
	if not permit_edge_scrool: return
	if is_panning or follow_enabled:
		return
	
	var viewport:Viewport = camera.get_viewport()
	var mouse_pos:Vector2 = viewport.get_mouse_position()
	var viewport_size:Vector2 = viewport.get_visible_rect().size
	
	var scroll_dir:Vector2 = Vector2.ZERO
	
	if mouse_pos.x < EDGE_SCROLL_MARGIN:
		scroll_dir.x = -1.0
	elif mouse_pos.x > viewport_size.x - EDGE_SCROLL_MARGIN:
		scroll_dir.x = 1.0
	
	if mouse_pos.y < EDGE_SCROLL_MARGIN:
		scroll_dir.y = -1.0
	elif mouse_pos.y > viewport_size.y - EDGE_SCROLL_MARGIN:
		scroll_dir.y = 1.0
	
	if scroll_dir != Vector2.ZERO:
		target_position = _clamp_position(
			target_position + scroll_dir.normalized() * EDGE_SCROLL_SPEED * delta
		)
## Handle following an entity
func _handle_follow()->void:
	if not follow_enabled or follow_uid == -1:
		return
	
	var pos:Vector2 = REG.get_ent_position(follow_uid)
	if pos != Vector2.ZERO:
		target_position = _clamp_position(pos)
## Centers the camera on the setted [member follow_uid] when 'space' is pressed.
func _handle_quick_follow()->void:
	if follow_uid < 0: return
	
	if Input.is_action_just_released("space"):
		var pos:Vector2 = REG.get_ent_position(follow_uid)
		if pos != Vector2.ZERO:
			target_position = _clamp_position(pos)
## Handle left-click entity clicking
func _handle_click_search_display()->void:
	if not is_panning and Input.is_action_just_released("mouse_click"):
		var world_pos:Vector2 = camera.get_canvas_transform().affine_inverse() * camera.get_viewport().get_mouse_position()
		#_draw_rect_nodes()
		var clicked_uid:int = _find_entity_at_position(world_pos)
		if clicked_uid >= 0:
			#REG._display_entity_info(clicked_uid)
			var info:InformationComponent = REG.get_component(clicked_uid, REG.C_FLAGS.INFO)
			if info:
				info.is_active = !info.is_active
			var mem:MemoryComponent = REG.get_component(clicked_uid, REG.C_FLAGS.MEMORY)
			if mem:
				mem.draw_vision = !mem.draw_vision
func _find_entity_at_position(world_pos:Vector2)->int:
	var entities:Array[int] = REG.get_entities_by(REG.C_FLAGS.VISUAL | REG.C_FLAGS.MOVE)
	var sort_y:Array[Dictionary] = []
	
	for uid:int in entities:
		var mov:MovementComponent = REG.get_component(uid, REG.C_FLAGS.MOVE)
		if mov:
			sort_y.append({"uid": uid, "y": mov.position.y})
	
	sort_y.sort_custom(func(a:Dictionary, b:Dictionary)->bool: return a.y > b.y)
	
	for entry:Dictionary in sort_y:
		var uid:int = entry.uid
		var vis:VisualComponent = REG.get_component(uid, REG.C_FLAGS.VISUAL)
		var mov:MovementComponent = REG.get_component(uid, REG.C_FLAGS.MOVE)
		
		if not vis or not mov:
			continue
		
		var sprite_rect:Rect2 = _get_expanded_sprite_rect(vis, mov)
		
		if sprite_rect.has_point(world_pos):
			return uid
	
	return -1
## Get expanded world-space rectangle for easier clicking
func _get_expanded_sprite_rect(vis:VisualComponent, mov:MovementComponent)->Rect2:
	var sprite:Node = vis.sprite
	var pos:Vector2 = mov.position
	var rect:Rect2 = Rect2()
	
	match vis.type:
		VisualComponent.TYPES.STATIC, VisualComponent.TYPES.ANIMATED:
			var anim_sprite:AnimatedSprite2D = sprite as AnimatedSprite2D
			if anim_sprite and anim_sprite.sprite_frames:
				var frames:SpriteFrames = anim_sprite.sprite_frames
				var anim_name:String = vis.current_animation if frames.has_animation(vis.current_animation) else "idle"
				if frames.has_animation(anim_name) and frames.get_frame_count(anim_name) > 0:
					var frame_idx:int = anim_sprite.frame if anim_sprite.frame < frames.get_frame_count(anim_name) else 0
					var texture:Texture2D = frames.get_frame_texture(anim_name, frame_idx)
					if texture:
						var size:Vector2 = texture.get_size()
						var offset:Vector2 = anim_sprite.offset
						rect = Rect2(pos + offset, size)
		VisualComponent.TYPES.DEBUG:
			var color_rect:ColorRect = sprite as ColorRect
			if color_rect:
				rect = Rect2(pos + color_rect.position, color_rect.size)
	
	# If we couldn't get a rect, use grid position as fallback
	if rect.size == Vector2.ZERO:
		rect = Rect2(pos - Vector2.ONE * REG.SCALE * 0.5, Vector2.ONE * REG.SCALE)
	
	# Expand by tolerance for easier clicking
	rect = rect.grow(CLICK_AREA)
	return rect
## Smooth movement to target position
func _smooth_move_to_target()->void:
	if position.distance_to(target_position) < 2.0:
		position = target_position
		acceleration = 0.0
		return
	
	position = position.move_toward(
		target_position, 
		BASE_SPEED + acceleration
	)
	acceleration = clampf(acceleration + 1.0, 0.0, BASE_SPEED * 2.0)

## Clamp camera position to world bounds
func _clamp_position(pos:Vector2)->Vector2:
	return pos.clamp(world_min, world_max)

## Cinematic: Move camera to a specific position
func move_to(pos:Vector2)->void:
	follow_enabled = false
	target_position = _clamp_position(pos)
	acceleration = 0.0

## Cinematic: Follow an entity by UID
func follow_entity(uid:int)->void:
	if not REG._is_valid_entity(uid):
		push_warning("[CameraManager] Cannot follow invalid entity: %d" % uid)
		return
	
	follow_uid = uid
	follow_enabled = true

## Stop following current entity
func stop_follow()->void:
	follow_enabled = false
	follow_uid = -1

## Cinematic: Camera shake effect
func shake(intensity:float = 5.0, duration:float = 0.3)->void:
	if not is_instance_valid(camera):
		return
	
	#var original_pos:Vector2 = position
	var shake_tween:Tween = camera.create_tween()
	
	var shake_count:int = int(duration * 60.0)
	for i:int in shake_count:
		var offset:Vector2 = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		shake_tween.tween_property(
			camera, 
			"offset", 
			offset, 
			duration / shake_count
		)
	
	shake_tween.tween_property(camera, "offset", Vector2.ZERO, 0.1)

## Set world boundaries for camera clamping
func set_world_bounds(min_pos:Vector2, max_pos:Vector2)->void:
	world_min = min_pos
	world_max = max_pos

var debug_nodes:Array = []
func _draw_rect_nodes()->void:
	for node:Node in debug_nodes:
		node.queue_free()
	debug_nodes.clear()
	for posi:Vector2i in REG.get_system(MovementSystem).grid_positions:
		var point:ColorRect = ColorRect.new()
		point.position = posi - Vector2i(position)
		point.size = Vector2.ONE * REG.SCALE
		debug_nodes.append(point)
		add_child(point)
