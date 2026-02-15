## Concrete archetype for NPC villagers with AI behavior
class_name VillagerType
extends EntityArchetype

## Pool of random names for villagers
const FEMALE_NAMES:Array[String] = ["Rita", "Elya", "Randa", "Mira", "Lysa", "Kara"]
const MALE_NAMES:Array[String] = ["Bran", "Tomas", "Erik", "Alden", "Jorin"]

func _init() -> void:
	archetype = "Villager"
	
	# Visual
	sprite_type = VisualComponent.SpriteType.ANIMATED
	anim_key = "f_human"
	
	# Movement
	moves = true
	is_solid = true
	mov_type = MovementComponent.Movable.Flag.GROUND
	mov_speed = 5.0
	
	# Stats
	has_stats = true
	blood_max = 100.0
	blood_regen = 0.1
	energy_max = 100.0
	energy_regen = 0.5
	hunger_max = 100.0
	hunger_regen = -0.2
	thirst_max = 100.0
	thirst_regen = -0.3
	
	# AI
	has_ai = true
	# TODO: Load from behavior resources once Phase 2 is complete
	behavior_keys = ["flee", "rest", "seek_food", "wander", "idle"]
	
	# Animation
	has_animations = true
	
	# Information
	has_information = true
	gender = "Female"
	show_ui = true
	
	# Not player-controlled
	is_actor = false

## Override to randomize villager names
func spawn(REG:REGISTRY, position:Vector2 = Vector2.ZERO, overrides:Dictionary = {})->int:
	# Auto-generate random name if not provided
	if not overrides.has("display_name"):
		var gen: String = overrides.get("gender", gender)
		if gen == "Male":
			overrides["display_name"] = MALE_NAMES.pick_random()
		else:
			overrides["display_name"] = FEMALE_NAMES.pick_random()
	
	# Randomize sprite variant if not specified
	if not overrides.has("anim_key"):
		var variants:Array[String] = ["f_human", "f_dwarf", "f_ranger", "f_woodcutter"]
		overrides["anim_key"] = variants.pick_random()
	
	return super.spawn(REG, position, overrides)
