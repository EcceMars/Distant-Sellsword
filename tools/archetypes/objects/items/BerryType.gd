@icon("res://assets/img/sprite_img/items/red_berries.png")
class_name BerryType
extends EntityType

func _init(specific:String = "")->void:
	if specific:
		_load_specific(specific)
	else:
		data = EntityData.new()
func _load_specific(_key:String)->bool:
	var model:BerryType = ResourceLoader.load("res://tools/archetypes/objects/items/" + _key + ".tres")
	if not model: return false
	data = model.data
	return true
