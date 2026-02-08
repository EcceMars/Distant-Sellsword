class_name BaseComponent
extends Resource

static var REGISTRY:Dictionary[Script, String] = {
	BehaviorComponent: "BehaviorComponent",
	ControllerComponent: "ControllerComponent",
	HealthComponent: "HealthComponent",
	MovementComponent: "MovementComponent",
	VisualComponent: "VisualComponent"
}

func in_registry()->String:
	return REGISTRY.get(get_script())
func clear()->void: pass
