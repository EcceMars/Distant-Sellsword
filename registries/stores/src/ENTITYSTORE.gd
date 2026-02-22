class_name ENTITYSTORE
extends Resource

enum TYPES {
	ACTOR,
	BERRY,
	BUSH,
	DUCK,
	TREE,
	VILLAGER,
}

## Maps each [enum Type] to its [EntityType] script. Add new archetypes here.
var SCRIPTS:Dictionary[TYPES, GDScript] = {
	TYPES.ACTOR: ActorType,
	TYPES.BERRY: BerryType,
	TYPES.BUSH: BushType,
	TYPES.DUCK: AnimalType,
	TYPES.TREE: TreeType,
	TYPES.VILLAGER: VillagerType
	}

func get_type(type:TYPES, specific:String = "")->EntityType:
	if not SCRIPTS.get(type): return null
	return SCRIPTS.get(type).new(specific)
