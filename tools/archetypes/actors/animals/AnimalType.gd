@icon("res://assets/img/icons/duck_icon.png")
class_name AnimalType
extends EntityType

func _init(specific:String = "")->void:
	if specific:
		_load_specific(specific)
	else:
		data = EntityData.new()
func _load_specific(_key:String)->bool:
	var model:AnimalType = ResourceLoader.load("res://tools/archetypes/actors/animals/" + _key + ".tres")
	if not model: return false
	data = model.data
	return true
