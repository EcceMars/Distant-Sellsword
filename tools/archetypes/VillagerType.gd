class_name VillagerType
extends EntityArchetype

func _init()->void:
	label = "Villager"
	data.sprite_type = VisualComponent.SpriteType.ANIMATED
	data.sprite_key = "f_human"
	data.moves = true
	data.is_solid = true
	data.has_stats = true
	data.behavior_keys = ["flee", "rest", "wander", "idle"]
	data.has_animations = true
	data.has_information = true

func _prepare()->void:
	data.char_name = REG.DATA.female_names.pick_random()
	data.sprite_key = ["f_human", "f_dwarf", "f_ranger"].pick_random()
