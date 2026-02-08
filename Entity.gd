@icon("res://_icon.svg")
class_name Entity
extends RefCounted

var uid:int = -1
var components:Dictionary[String, BaseComponent] = {}

func add_component(component:BaseComponent, override:bool = false)->bool:
	var s_name:String = component.in_registry()
	if components.has(s_name) and not override:
		return false
	components[s_name] = component
	return true
func get_component(component:Script)->BaseComponent:
	return components.get(component.get_global_name())
func _to_string()->String:
	var comps:String = ""
	for component in components:
		comps += component + "\n\t"
	return '\n' + str(uid) + ":\n\t" + comps
