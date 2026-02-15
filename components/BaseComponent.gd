class_name BaseComponent
extends RefCounted

var flag:Flag = Flag.NONE
## Bitmask table for components
enum Flag {
	NONE = 0,
	
	ACTOR			= 1 << 0,		## For handling player input
	ANIMATION_STATE	= 1 << 1,		## For handling animations
	BEHAVIOR		= 1 << 2,		## AI behavior
	INFORMATION		= 1 << 3,		## Holds data for UI, exposing the [StatsComponent]
	ITEM			= 1 << 4,		## Used for item entities (e.g. goods, resources)
	MOVEMENT		= 1 << 5,		## Holds position, and, if movable, relevant data
	STATS			= 1 << 6,		## General data about the entity (e.g. name, hitpoints)
	TERRAIN			= 1 << 7,		## Describes terrain data (e.g. grass, water)
	VISUAL			= 1 << 8,		## Holds references to the visual node that [REGISTRY.CANVAS] carries
	WEATHER			= 1 << 9		## Describes a quick phenomenom (e.g. wind, thunder etc.)
	}

func _to_string()->String:
	return get_script().get_global_name()
