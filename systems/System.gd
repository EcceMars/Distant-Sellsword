@icon("res://assets/icons/system_icon.png")
class_name System
extends RefCounted

static var REGISTRY:Dictionary[Script, String] = {
	BehaviorSystem: "BehaviorSystem",
	ControllerSystem: "ControllerSystem",
	HealthSystem: "HealthSystem",
	InformationSystem: "InformationSystem",
	MovementSystem: "MovementSystem",
	VisualSystem: "VisualSystem"
}

func process(_world:ECS_MANAGER)->void: pass
## Returns the name of the [System] as [String].
## If no script is provided or if the script does not extends [System], this func will either return null (error) or the [System] class that called it 
func in_registry(script:Script = null)->String:
	if script:
		return REGISTRY.get(script)
	return REGISTRY.get(get_script())
func _to_string()->String:
	return get_script().get_global_name()
