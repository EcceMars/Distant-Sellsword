class_name VisualComponent
extends BaseComponent

const TYPES = REG.DATA.SPRITES.TYPES

var sprite:Node = null
var type:TYPES = TYPES.DEBUG

var queue_destroy:bool = false
var destroy_time:float = 0.0

## Animation state (only used when sprite_type == ANIMATED)
var current_animation:String = "idle"
var previous_animation:String = "idle"
var animation_speed:float = 1.0

func _init(
	_type:TYPES = TYPES.DEBUG,
	sprite_frames:SpriteFrames = null,  ## Visual key for the [SpriteRegistry]
	position:Vector2i = Vector2i.ZERO,
	debug_color:Color = Color.PURPLE) -> void:
	type = _type
	flag = Flag.VISUAL
	_create_sprite(sprite_frames, position, debug_color)

func _create_sprite(sprite_frames:SpriteFrames, position:Vector2i, debug_color:Color) -> void:
	match type:
		TYPES.STATIC, TYPES.ANIMATED:
			sprite = AnimatedSprite2D.new()
			if sprite_frames:
				sprite.sprite_frames = sprite_frames
				var frame_size:Vector2 = sprite_frames.get_frame_texture(REG.SP_REG.get_default_anim_name(sprite_frames), 0).get_size()
				sprite.offset = _offset(frame_size)
			else:
				push_warning("[VisualComponent] Animation '%s' not found, using debug visual" % sprite_frames)
				_default(position, debug_color)
				return
			sprite.position = position
			sprite.centered = false
		
		TYPES.DEBUG:
			_default(position, debug_color)
			return
	
	sprite.name = "sprite_%5d" % randi()
	
	REG.ENT_LAYER.add_child(sprite)
func _default(position:Vector2i, color:Color)->void:
	sprite = ColorRect.new()
	sprite.color = color
	sprite.name = "def_sprite_%5d" % randi()
	sprite.size = Vector2.ONE * 16
	sprite.position = position * -0.5
	sprite.offset_bottom = true
	
	REG.ENT_LAYER.add_child(sprite)
func _offset(size:Vector2)->Vector2:
	var offset:Vector2 = Vector2.ZERO
	var factor:float = (size.y / (size.y / REG.SCALE))
	if size.x > REG.SCALE: offset.x = - factor
	if size.y > REG.SCALE: offset.y = - size.y + factor
	
	return offset
func clear()->void:
	queue_destroy = true
func _to_string()->String:
	var message:String = get_script().get_global_name()
	message += " is " + TYPES.keys()[type]
	return message
