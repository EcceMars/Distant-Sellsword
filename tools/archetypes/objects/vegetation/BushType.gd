@icon("res://assets/img/sprite_img/vegetation/fruit_bush_icon.png")
class_name BushType
extends EntityType

func _init(specific:String = "")->void:
	if specific:
		_load_specific(specific)
	else:
		data = EntityData.new()
func _load_specific(_key:String)->bool:
	var model:BushType = ResourceLoader.load("res://tools/archetypes/objects/vegetation/" + _key + ".tres")
	if not model: return false
	data = model.data
	return true
