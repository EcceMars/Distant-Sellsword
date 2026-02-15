## Base archetype for items (food, water, resources, tools)
class_name ItemType
extends EntityArchetype

## Item configuration
@export_group("Item Properties")
@export var item_type: ItemComponent.ItemType = ItemComponent.ItemType.MISC
@export var item_name: String = "Item"
@export var nutrition: float = 0.0
@export var hydration: float = 0.0
@export var stack_size: int = 1
@export var max_stack: int = 99
@export var weight: float = 1.0
@export var consumable: bool = false

func _init() -> void:
	archetype = "Item"
	
	# Items have position and visual, but don't move
	has_position = true
	is_solid = false  # Can walk over items
	moves = false
	
	# Visual
	is_visible = true
	sprite_type = VisualComponent.SpriteType.ANIMATED
	
	# No stats, AI, or animations
	has_stats = false
	has_ai = false
	has_animations = false
	has_information = false
	is_actor = false

func spawn(REG: REGISTRY, position: Vector2 = Vector2.ZERO, overrides: Dictionary = {}) -> int:
	var uid: int = super.spawn(REG, position, overrides)
	if uid == -1:
		return -1
	
	# Add ItemComponent
	_add_item_component(REG, uid, overrides)
	return uid

func _add_item_component(REG: REGISTRY, uid: int, overrides: Dictionary) -> void:
	var component := ItemComponent.new(
		overrides.get("item_type", item_type),
		overrides.get("item_name", item_name),
		overrides.get("nutrition", nutrition),
		overrides.get("hydration", hydration),
		overrides.get("stack_size", stack_size),
		overrides.get("consumable", consumable)
	)
	
	component.max_stack = overrides.get("max_stack", max_stack)
	component.weight = overrides.get("weight", weight)
	component.on_ground = true
	
	REG.add_component(uid, component)
