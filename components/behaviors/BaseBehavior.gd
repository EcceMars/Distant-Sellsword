## Base class for all AI behaviors.
class_name BaseBehavior
extends Resource

enum Type {
	FLEE,
	IDLE,
	INPUT,
	REST,
	SEEK_FOOD,
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

@export_category("Health cost")
@export var blood:float = 0.5
@export var energy:float = 0.01
@export var hunger:float = 0.05
@export var thirst:float = 0.01

func get_priority()->float: return 0.0
func act(_uid:int)->void: pass
func on_enter()->void: pass
func on_exit()->void: pass

func _tire(uid:int)->void:
	var stats:StatsComponent = REG.get_component(uid, REG.C_FLAGS.STATS)
	if not stats: return
	
	if stats.blood: stats.blood.hurt(blood)
	if stats.energy: stats.energy.hurt(energy)
	if stats.hunger: stats.hunger.hurt(hunger)
	if stats.thirst: stats.thirst.hurt(thirst)
func _to_string()->String:
	return str(type) + ": " + get_script().get_global_name()
