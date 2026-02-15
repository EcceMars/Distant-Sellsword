## Concrete archetype for trees and vegetation
## Demonstrates static entities that could become movable at runtime
class_name TreeType
extends EntityArchetype

func _init() -> void:
	archetype = "Tree"
	
	# Visual
	sprite_type = VisualComponent.SpriteType.ANIMATED
	anim_key = "pine_tree"
	
	# Movement - has position but cannot move (yet!)
	moves = false
	is_solid = true
	
	has_stats = false
	has_ai = false
	has_animations = false
	has_information = false
	is_actor = false

## Example of archetype with variant support
func spawn(REG: REGISTRY, position: Vector2 = Vector2.ZERO, overrides: Dictionary = {}) -> int:
	# Could randomize tree types here
	if not overrides.has("anim_key"):
		# Future: ["pine_tree", "oak_tree", "willow_tree"].pick_random()
		overrides["anim_key"] = "pine_tree"
	
	return super.spawn(REG, position, overrides)
