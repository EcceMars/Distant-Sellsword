## Archetype for food items
class_name BerriesItemType
extends EntityArchetype

func _init()->void:
	archetype = "Berries"
	
	# Visual
	sprite_type = VisualComponent.SpriteType.STATIC
	anim_key = "berries"  # You'll need to add this sprite
	
	# Movement - items have position but don't move on their own
	moves = false
	is_solid = false
	
	# No stats, behavior, animations, or actor control
	has_stats = false
	has_behavior = false
	has_animations = false
	has_information = false
	is_actor = false

## Override to add ItemComponent
func create(overrides:Dictionary = {})->int:
	var uid:int = super.create(overrides)
	if uid == -1: return -1
	
	# Add item component
	var item_type:String = overrides.get("item_type", "food")
	var item:ItemComponent = ItemComponent.new(item_type)
	
	# Set initial location
	var mov:MovementComponent = REG.get_component(uid, REG.C_FLAGS.MOVE)
	if mov:
		item.world_position = mov.position
		item.owner_uid = -1  # Start on ground
	
	REG.add_component(uid, item)
	REG.IT_REG.register_item(uid, item)
	
	return uid
