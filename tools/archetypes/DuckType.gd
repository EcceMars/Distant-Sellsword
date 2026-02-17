## Concrete archetype for trees and vegetation
## Demonstrates static entities that could become movable at runtime
class_name DuckType
extends EntityArchetype

func _init() -> void:
	archetype = "Duck"
	
	# Visual
	sprite_type = VisualComponent.SpriteType.ANIMATED
	anim_key = "duck"
	
	# Movement - has position but cannot move (yet!)
	moves = true
	is_solid = false
	
	has_stats = true
	has_behavior = true
	has_animations = true
	has_information = true
	is_actor = false

## Example of archetype with variant support
func spawn(overrides:Dictionary = {}) -> int:
	# Could randomize tree types here
	if not overrides.has("anim_key"):
		overrides["anim_key"] = "duck"
	
	return super.create(overrides)
