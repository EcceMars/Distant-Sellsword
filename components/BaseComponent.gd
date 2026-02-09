@icon("res://assets/icons/component_icon.png")
class_name BaseComponent extends Resource

static var REGISTRY:Dictionary[Script, String] = {
	BehaviorComponent: "BehaviorComponent",
	ControllerComponent: "ControllerComponent",
	HealthComponent: "HealthComponent",
	InformationComponent: "InformationComponent",
	MovementComponent: "MovementComponent",
	VisualComponent: "VisualComponent"
}

## Returns the name of the [BaseComponent] as [String].
## If no script is provided or if the script does not extends [BaseComponent], this func will either return null (error) or the [BaseComponent] class that called it 
func in_registry(script:Script = null)->String:
	if script:
		return REGISTRY.get(script)
	return REGISTRY.get(get_script())
func clear()->void: pass
