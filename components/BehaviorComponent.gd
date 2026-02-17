class_name BehaviorComponent
extends BaseComponent

## Current behavior
var active_behavior:BaseBehavior = null
## List of all behaviors this entity has
var behaviors:Dictionary[String, BaseBehavior] = {}

func _init(behavior_keys:Array[String])->void:
	flag = Flag.BEHAVIOR
	
	for key:String in behavior_keys:
		var behavior:BaseBehavior = REG.BE_REG.load_behavior(key)
		behaviors[key] = behavior
	# Set initial behavior (idle or first available)
	if behaviors.size() > 0:
		for key:String in behaviors:
			var behavior:BaseBehavior = behaviors[key]
			if behavior.behavior_name == "Idle":
				active_behavior = behavior
				break
		if not active_behavior:
			active_behavior = behaviors.get("Idle")
func add_behavior(behavior:BaseBehavior, override:bool = false)->BaseBehavior:
	if not override and behavior.get(behavior.behavior_name): return null
	behaviors[behavior.behavior_name] = behavior
	return behaviors[behavior.behavior_name]
func get_behavior(name:String)->BaseBehavior:
	return behaviors.get(name)
func has_behavior(name:String)->bool:
	return behaviors.has(name)
