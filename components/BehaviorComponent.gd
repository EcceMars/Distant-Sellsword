class_name BehaviorComponent
extends BaseComponent

## Current active behavior
var active_behavior: Behavior = null

## List of all behaviors this entity can use
var behaviors: Array[Behavior] = []

## Behavior keys used to initialize (for debugging)
var _behavior_keys: Array[String] = []

## Initializes with behavior keys or preset
## [param behavior_keys] - Array of behavior keys or single preset name
func _init(REG:REGISTRY, behavior_keys:Variant = []) -> void:
	flag = Flag.BEHAVIOR
	
	if behavior_keys is String:
		# It's a preset key
		_behavior_keys = BehaviorRegistry.PRESETS.get(behavior_keys, [])
		behaviors = REG.BE_REG.get_preset(behavior_keys)
	elif behavior_keys is Array:
		# It's a list of behavior keys
		_behavior_keys.assign(behavior_keys)
		if behavior_keys.size() > 0:
			behaviors = REG.BE_REG.get_behaviors(behavior_keys)
		else:
			# Default to peaceful preset
			behaviors = REG.BE_REG.get_preset("peaceful")
	
	# Set initial behavior (idle or first available)
	if behaviors.size() > 0:
		for behavior in behaviors:
			if behavior.behavior_name == "Idle":
				active_behavior = behavior
				break
		if not active_behavior:
			active_behavior = behaviors[0]

## Gets debug string for current behavior state
func get_status(uid: int) -> String:
	if not active_behavior:
		return "Entity %d is mindless..." % uid
	return "Entity %d: %s" % [uid, active_behavior.behavior_name]
