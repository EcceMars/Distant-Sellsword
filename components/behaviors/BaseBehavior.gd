## Base class for all AI behaviors.
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
class STATE_MACHINE:
	enum SearchState {
	START,			## Not searching
	LOOK_FRONT,		## First look in current direction
	WAIT_FIRST,		## Waiting after first look
	TURN,			## Turning around
	LOOK_SECOND,	## Second look in opposite direction
	WAIT_SECOND,	## Waiting after second look
	USE_MEMORY,		## Fall back to last known position
	WANDER_ON		## If no item is found either in the new or the older memory entries
	}

	var _state:SearchState = SearchState.START
