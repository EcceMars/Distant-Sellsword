@icon("res://assets/img/icons/system_icon.png")
## Extends from [Object] as no system should be unloaded while the game is running.
class_name BaseSystem
extends Object

const ANIM_STATE_FLAG:BaseComponent.Flag = BaseComponent.Flag.ANIMATION_STATE
const BEHAV_FLAG:BaseComponent.Flag = BaseComponent.Flag.BEHAVIOR
const INFO_FLAG:BaseComponent.Flag = BaseComponent.Flag.INFORMATION
const MOV_FLAG:BaseComponent.Flag = BaseComponent.Flag.MOVEMENT
const STATS_FLAG:BaseComponent.Flag = BaseComponent.Flag.STATS
const VIS_FLAG:BaseComponent.Flag = BaseComponent.Flag.VISUAL

static var TYPES:Dictionary[GDScript, String] = {
	AnimationSystem: "AnimationSystem",
	#BehaviorSystem: "BehaviorSystem",
	InputSystem: "InputSystem",
	StatsSystem: "StatsSystem",
	#InformationSystem: "InformationSystem",
	MovementSystem: "MovementSystem",
	VisualSystem: "VisualSystem"
	}

## Updating base function for all systems
func process()->void: pass
## Returns the name of the [System] as [String].
## If no script is provided or if the script does not extends [System], this func will either return null (error) or the [System] class that called it 
func in_registry(script:GDScript = null)->String:
	if script:
		return TYPES.get(script)
	return TYPES.get(get_script())
