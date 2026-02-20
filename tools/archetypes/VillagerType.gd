class_name VillagerType
extends Entity

func _init()->void:
	label = "Villager"
	data.sprite_type = VisualComponent.SpriteType.ANIMATED
	data.sprite_key = "f_human"
	data.moves = true
	data.is_solid = true
	data.has_stats = true
	data.behavior_keys = [
		#BaseBehavior.Type.FLEE,
		#BaseBehavior.Type.REST,
		BaseBehavior.Type.SEEK_FOOD,
		BaseBehavior.Type.SEEK_WATER,
		BaseBehavior.Type.WANDER,
		BaseBehavior.Type.IDLE,
	]
	data.has_animations = true
	data.has_information = true
	data.has_memory = true

func _prepare()->void:
	data.char_name = REG.DATA.FEMALE_NAMES.pick_random()
	data.sprite_key = ["f_human", "f_dwarf", "f_ranger"].pick_random()
