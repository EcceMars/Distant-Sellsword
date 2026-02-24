## Base class for all AI behaviors.
@icon("res://assets/img/icons/behavior_icon.png")
class_name BaseBehavior
extends Resource

enum Type {
	FLEE,
	IDLE,
	INPUT,
	REST,
	SEEK_FOOD,
	SEEK_WATER,
	WANDER
	}

var type:Type = Type.IDLE

@export var behavior_name:String = "Unnamed"
## Description for editor reference
@export_multiline var description:String = ""
## Whether this behavior is enabled
@export var active:bool = false
## Priority threshold
@export_range(0.0, 1.0, 0.1) var priority:float = 0.1

func get_priority(_uid:int)->float: return 0.0
func act(_uid:int)->void: pass
func on_enter()->void: pass
func on_exit()->void: pass

func _to_string()->String:
	return str(type) + ": " + get_script().get_global_name()
