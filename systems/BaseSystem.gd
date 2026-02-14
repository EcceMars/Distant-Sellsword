@icon("res://assets/img/icons/system_icon.png")
class_name BaseSystem
extends RefCounted

const ACTOR_FLAG:BaseComponent.Flag = BaseComponent.Flag.ACTOR
const BEHAV_FLAG:BaseComponent.Flag = BaseComponent.Flag.BEHAVIOR
const INFO_FLAG:BaseComponent.Flag = BaseComponent.Flag.INFORMATION
const MOV_FLAG:BaseComponent.Flag = BaseComponent.Flag.MOVEMENT
const STATS_FLAG:BaseComponent.Flag = BaseComponent.Flag.STATS
const VIS_FLAG:BaseComponent.Flag = BaseComponent.Flag.VISUAL

static var TYPES:Dictionary[Script, String] = {
	ActorSystem: "ActorSystem",
	BehaviorSystem: "BehaviorSystem",
	StatsSystem: "StatsSystem",
	InformationSystem: "InformationSystem",
	MovementSystem: "MovementSystem",
	VisualSystem: "VisualSystem"
}

## Updating base function for all systems
func process(_REG:REGISTRY)->void: pass
## Returns the name of the [System] as [String].
## If no script is provided or if the script does not extends [System], this func will either return null (error) or the [System] class that called it 
func in_registry(script:Script = null)->String:
	if script:
		return TYPES.get(script)
	return TYPES.get(get_script())
