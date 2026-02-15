class_name VisualComponent
extends BaseComponent

enum SpriteType {
	DEBUG,      ## ColorRect for debugging
	STATIC,     ## Sprite2D for non-animated
	ANIMATED    ## AnimatedSprite2D
}

var sprite:Node = null
var sprite_type:SpriteType = SpriteType.DEBUG
var queue_destroy:bool = false

## Animation state (only used when sprite_type == ANIMATED)
var current_animation:String = "idle"
var animation_speed:float = 1.0

func _init(
	REG:REGISTRY,
	_sprite_type:SpriteType = SpriteType.DEBUG,
	anim_key:String = ""  ## SpriteFrames for animated, Texture2D for static
	)->void:
	sprite_type = _sprite_type
	flag = Flag.VISUAL
	_create_sprite(REG, anim_key)
func _create_sprite(REG:REGISTRY, anim_key:String)->void:
	match sprite_type:
		SpriteType.STATIC:
			sprite = Sprite2D.new()
			if anim_key:
				var texture = DataStore.get_frames(anim_key)
				if texture is Texture2D:
					sprite.texture = texture
			sprite.centered = true
		
		SpriteType.ANIMATED:
			sprite = AnimatedSprite2D.new()
			if anim_key:
				var frames = DataStore.get_frames(anim_key)
				if frames is SpriteFrames:
					sprite.sprite_frames = frames
			sprite.centered = true
		
		SpriteType.DEBUG:
			_default(REG)
			return
	
	sprite.name = "sprite_%d" % Time.get_unix_time_from_system()
	REG.CANVAS.add_child(sprite)
	REG.visual_nodes.append(sprite)
func _default(REG:REGISTRY)->void:
	sprite = ColorRect.new()
	sprite.color = Color.PURPLE
	sprite.name = "def_sprite_" + str(Time.get_unix_time_from_system())
	sprite.size = Vector2.ONE * 16
	sprite.position = sprite.size * -0.5
	REG.CANVAS.add_child(sprite)
	REG.visual_nodes.append(sprite)
func clear()->void: queue_destroy = true
