## Base class for entity archetypes - blueprints for entity creation.
## Archetypes provide convenient defaults but don't restrict runtime modification.
## The ECS remains fully dynamic - components can be added/removed freely.
@icon("res://assets/img/icons/main_icon.png")
class_name EntityArchetype
extends Resource

## Archetype display name, set in each subtype's [method _init].
var label:String = "Unnamed"
## All configuration for this archetype. Subtypes populate in [method _init].
var data:Data = Data.new()

## Populates [member data] with archetype defaults. Override in each subtype.
func _init()->void: pass

## Hook for runtime randomisation before [method _build] runs.
## Override in subtypes that need name/sprite variation.
func _prepare()->void: pass

## Assembles and registers a new entity from [member data].
## Returns the new entity UID, or -1 on failure.
func _build()->int:
	_prepare()
	var uid:int = REG.create_entity()
	if uid == -1:
		push_error("[EntityArchetype] Registry full, cannot spawn: %s" % label)
		return -1
	_add_movement(uid)
	_add_visual(uid)
	if data.has_stats:					_add_stats(uid)
	if data.has_animations:				_add_animation_state(uid)
	if data.behavior_keys.size() > 0:	_add_behavior(uid)
	return uid

## Override in subtypes that need post-build logic (e.g. ItemComponent registration).
func _post_build(_uid:int)->void: pass

func _add_movement(_uid:int)->void: pass
func _add_visual(_uid:int)->void: pass
func _add_stats(_uid:int)->void: pass
func _add_animation_state(_uid:int)->void: pass
func _add_behavior(_uid:int)->void: pass
## All configuration data for a single archetype.
## Modify members before calling [method EntityArchetype._build] for runtime customisation.
class Data:
	## Visual
	var sprite_type:VisualComponent.SpriteType = VisualComponent.SpriteType.DEBUG
	var sprite_key:String = ""
	var debug_color:Color = Color.PURPLE
	## Movement
	var moves:bool = false
	var is_solid:bool = false
	var move_type:MovementComponent.Movable.Flag = MovementComponent.Movable.Flag.GROUND
	var move_speed:float = 1.0
	## Stats
	var has_stats:bool = false
	var blood_max:float = 100.0
	var blood_regen:float = 0.1
	var energy_max:float = 100.0
	var energy_regen:float = 0.5
	var hunger_max:float = 100.0
	var hunger_regen:float = -0.2
	var thirst_max:float = 100.0
	var thirst_regen:float = -0.3
	## Identity
	var char_name:String = ""
	var gender:String = "Female"
	## Behavior
	var behavior_keys:Array[String] = []
	## Flags
	var has_animations:bool = false
	var has_information:bool = false
	var is_actor:bool = false
