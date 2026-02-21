class_name StoneType
extends EntityType

func _init(specific:String = "")->void:
	if specific:
		_load_specific(specific)
	else:
		data = EntityData.new()
func _load_specific(_key:String)->bool:
	var model:StoneType = ResourceLoader.load("res://tools/archetypes/objects/vegetation/" + _key + ".tres")
	if not model: return false
	data = model.data
	return true
