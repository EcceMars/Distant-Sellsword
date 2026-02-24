## Base class for all AI behaviors.
@icon("res://assets/img/icons/behavior_icon.png")
class_name BaseBehavior
extends Resource

@export var behavior_name:String = "Unnamed"
## Description for editor reference
@export_multiline var description:String = ""
## Whether this behavior is enabled
@export var active:bool = false
## Priority threshold
@export_range(0.0, 1.0, 0.1) var priority:float = 0.1