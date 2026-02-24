@icon("res://assets/img/icons/mult_icon.png")
class_name VillagerType
extends EntityType

func _init(specific:String = "")->void:
	if specific:
		_load_specific(specific)
	else:
		data = EntityData.new()
	if not data.char_name:
		match data.gender:
			"Female": data.char_name = REG.DATA.LORE.FEMALE_NAMES.pick_random()
			"Male": data.char_name = REG.DATA.LORE.MALE_NAMES.pick_random()
func _load_specific(key:String)->bool:
	var model:VillagerType = ResourceLoader.load("res://tools/archetypes/actors/villagers/" + key + ".tres")
	if not model: return false
	data = model.data
	if data.has_btree:
		data.has_behavior = false
		data.btree_nodes.append(BTThirsty.new())
		data.behavior_keys.clear()
	return true
