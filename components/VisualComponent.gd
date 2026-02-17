class_name VisualComponent
extends BaseComponent

enum SpriteType {
	DEBUG,		## ColorRect for debugging
	STATIC,		## Sprite2D for non-animated
	ANIMATED	## AnimatedSprite2D
}

var sprite:Node = null
var sprite_type:SpriteType = SpriteType.DEBUG
var queue_destroy:bool = false

## Animation state (only used when sprite_type == ANIMATED)
var current_animation:String = "idle"
var previous_animation:String = "idle"
var animation_speed:float = 1.0

func _init(
	_sprite_type:SpriteType = SpriteType.DEBUG,
	sprite_key:String = "",  ## Visual key for the [SpriteRegistry]
	position:Vector2i = Vector2i.ZERO,
	debug_color:Color = Color.PURPLE) -> void:
	sprite_type = _sprite_type
	flag = Flag.VISUAL
	_create_sprite(sprite_key, position, debug_color)

func _create_sprite(sprite_key:String, position:Vector2i, debug_color:Color) -> void:
	match sprite_type:
		SpriteType.STATIC:
			sprite = Sprite2D.new()
			if sprite_key:
				var texture:Texture2D = REG.SP_REG.get_texture(sprite_key)
				if texture:
					sprite.texture = texture
					var texture_size:Vector2 = texture.get_size()
					sprite.offset = _offset(texture_size)
			sprite.position = position
			sprite.centered = false
		
		SpriteType.ANIMATED:
			sprite = AnimatedSprite2D.new()
			if sprite_key:
				var frames:SpriteFrames = REG.SP_REG.get_frames(sprite_key)
				if frames:
					sprite.sprite_frames = frames
					var frame_size:Vector2 = frames.get_frame_texture("idle", 0).get_size()
					sprite.offset = _offset(frame_size)
				else:
					push_warning("[VisualComponent] Animation '%s' not found, using debug visual" % sprite_key)
					_default(position, debug_color)
					return
			sprite.position = position
			sprite.centered = false
		
		SpriteType.DEBUG:
			_default(position, debug_color)
			return
	
	sprite.name = "sprite_%d" % Time.get_unix_time_from_system()
	
	REG.CANVAS.add_child(sprite)
	REG.visual_nodes.append(sprite)
func _default(position:Vector2i, color:Color)->void:
	sprite = ColorRect.new()
	sprite.color = color
	sprite.name = "def_sprite_" + str(Time.get_unix_time_from_system())
	sprite.size = Vector2.ONE * 16
	sprite.position = position * -0.5
	sprite.offset_bottom = true
	
	REG.CANVAS.add_child(sprite)
	REG.visual_nodes.append(sprite)
func _offset(size:Vector2)->Vector2:
	var offset:Vector2 = Vector2.ZERO
	var factor:float = (size.y / (size.y / REG.SCALE))
	if size.x > REG.SCALE: offset.x = - factor
	if size.y > REG.SCALE: offset.y = - size.y + factor
	
	return offset
func clear()->void:
	queue_destroy = true
