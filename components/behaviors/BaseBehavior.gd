## Base class for all AI behaviors.
class_name BaseBehavior
extends Resource

@export var behavior_name:String = "Unnamed"
## Description for editor reference
@export_multiline var description:String = ""
## Whether this behavior is enabled
@export var active:bool = false
## Priority threshold
@export_range(0.0, 1.0, 0.1) var priority:float = 0.1

func get_priority()->float: return 0.0
func act()->void: pass
func on_enter()->void: pass
func on_exit()->void: pass
