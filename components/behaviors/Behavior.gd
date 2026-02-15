## Base class for all AI behaviors.
class_name Behavior
extends Resource

## Shortcuts for common component flags
const MOV_FLAG:BaseComponent.Flag = BaseComponent.Flag.MOVEMENT
const STATS_FLAG:BaseComponent.Flag = BaseComponent.Flag.STATS
const BEHAV_FLAG:BaseComponent.Flag = BaseComponent.Flag.BEHAVIOR

## Display name for this behavior
@export var behavior_name:String = "Unnamed"

## Description for editor reference
@export_multiline var description:String = ""

## Whether this behavior is enabled
@export var enabled:bool = true

## Evaluates how urgent this behavior is for a given entity.
## Returns a float from 0.0 (not needed) to 1.0+ (critical).
## Higher priority behaviors take precedence.
func priority(_uid:int, _REG:REGISTRY)->float:
	if not enabled: return 0.0
	return 0.0

## Executes this behavior for a given entity.
## Called every frame while this behavior is active.
func act(_uid:int, _REG:REGISTRY)->void: pass

## Called once when behavior becomes active
func on_enter(_uid:int, _REG:REGISTRY)->void: pass

## Called once when behavior becomes inactive
func on_exit(_uid:int, _REG:REGISTRY)->void: pass

func _to_string() -> String: return behavior_name
