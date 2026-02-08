class_name System
extends RefCounted

func process(_world:ECS_MANAGER)->void: pass
func _to_string()->String:
	return get_script().get_global_name()
