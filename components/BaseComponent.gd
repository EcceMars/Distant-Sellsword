class_name BaseComponent
extends Resource

static var REGISTRY:Dictionary[Script, String] = {
	ControllerComponent: "ControllerComponent",
	MovementComponent: "MovementComponent",
	VisualComponent: "VisualComponent"
}

func in_registry()->String:
	return REGISTRY.get(get_script())
