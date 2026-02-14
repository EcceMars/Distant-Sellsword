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
	sprite_resource = null  ## SpriteFrames for animated, Texture2D for static
)->void:
	sprite_type = _sprite_type
	flag = Flag.VISUAL
	_create_sprite(REG, sprite_resource)

func _create_sprite(REG:REGISTRY, resource)->void:
	match sprite_type:
		SpriteType.STATIC:
			sprite = Sprite2D.new()
			if resource is Texture2D:
				sprite.texture = resource
			sprite.centered = true
		
		SpriteType.ANIMATED:
			sprite = AnimatedSprite2D.new()
			if resource is SpriteFrames:
				sprite.sprite_frames = resource
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
