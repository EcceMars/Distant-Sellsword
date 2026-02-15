## Base class for entity archetypes - blueprints for entity creation.
## Archetypes provide convenient defaults but don't restrict runtime modification.
## The ECS remains fully dynamic - components can be added/removed freely.
class_name EntityArchetype
extends Resource

## Human-readable archetype name
@export var archetype:String = "Unnamed"

## Visual configuration
@export_group("Visual")
@export var sprite_type:VisualComponent.SpriteType = VisualComponent.SpriteType.DEBUG
@export var anim_key:String = ""

## Movement configuration
@export_group("Movement")
@export var has_movement:bool = true
@export var is_solid:bool = true
@export var is_movable:bool = false
@export var movement_type:MovementComponent.Movable.Flag = MovementComponent.Movable.Flag.GROUND
@export var movement_speed:float = 1.0

## Stats configuration
@export_group("Stats")
@export var has_stats:bool = false
@export var blood_max:float = 100.0
@export var blood_regen:float = 0.1
@export var energy_max:float = 100.0
@export var energy_regen:float = 0.5
@export var hunger_max:float = 100.0
@export var hunger_regen:float = -0.2
@export var thirst_max:float = 100.0
@export var thirst_regen:float = -0.3

## AI configuration
@export_group("Behavior")
@export var has_behavior:bool = false
## Array of behavior resource paths or behavior class names
@export var behavior_keys:Array[String] = []

## Animation configuration
@export_group("Animation")
@export var has_animation_state:bool = false
## Custom animation mappings:AnimationStateComponent.State->animation_name
## If empty, uses default mappings from AnimationSystem
@export var animation_map:Dictionary = {}

## Information/UI configuration
@export_group("Information")
@export var has_information:bool = false
@export var display_name:String = ""
@export var gender:String = "Female"
@export var show_ui:bool = false

## Actor/Player control
@export_group("Control")
@export var is_actor:bool = false

## Creates an entity from this archetype.
## Returns the entity UID, or -1 on failure.
## [param position] - Spawn position (required if has_movement is true)
## [param overrides] - Dictionary for runtime overrides (e.g. {"display_name":"Bob"})
func spawn(REG:REGISTRY, position:Vector2 = Vector2.ZERO, overrides:Dictionary = {})->int:
	var uid:int = REG.create_entity()
	if uid == -1:
		push_error("[EntityArchetype] Registry full, cannot spawn %s" % archetype)
		return -1
	
	# Build components based on configuration
	_add_movement(REG, uid, position, overrides)
	_add_visual(REG, uid, overrides)
	_add_stats(REG, uid, overrides)
	_add_behavior(REG, uid, overrides)
	_add_animation_state(REG, uid, overrides)
	_add_information(REG, uid, overrides)
	_add_actor(REG, uid, overrides)
	
	return uid

## Override this in subclasses for custom component logic
func _add_movement(REG:REGISTRY, uid:int, position:Vector2, overrides:Dictionary)->void:
	if not has_movement:
		return
	
	var pos:Vector2 = overrides.get("position", position)
	var solid:bool = overrides.get("is_solid", is_solid)
	var movable:bool = overrides.get("is_movable", is_movable)
	var mov_type:MovementComponent.Movable.Flag = overrides.get("movement_type", movement_type)
	var speed:float = overrides.get("movement_speed", movement_speed)
	
	var component := MovementComponent.new(pos, solid, movable, mov_type, speed)
	REG.add_component(uid, component)

func _add_visual(REG:REGISTRY, uid:int, overrides:Dictionary)->void:
	var spr_type:VisualComponent.SpriteType = overrides.get("sprite_type", sprite_type)
	var spr_key:String = overrides.get("anim_key", anim_key)
	
	var component := VisualComponent.new(REG, spr_type, spr_key)
	REG.add_component(uid, component)

func _add_stats(REG:REGISTRY, uid:int, overrides:Dictionary)->void:
	if not has_stats:
		return
	
	var component := StatsComponent.new(
		overrides.get("blood_max", blood_max),
		overrides.get("blood_regen", blood_regen),
		overrides.get("energy_max", energy_max),
		overrides.get("energy_regen", energy_regen),
		overrides.get("hunger_max", hunger_max),
		overrides.get("hunger_regen", hunger_regen),
		overrides.get("thirst_max", thirst_max),
		overrides.get("thirst_regen", thirst_regen)
	)
	REG.add_component(uid, component)

func _add_behavior(REG:REGISTRY, uid:int, overrides:Dictionary)->void:
	if not has_behavior:
		return
	
	var keys:Array = overrides.get("behavior_keys", behavior_keys)
	var component := BehaviorComponent.new(REG)
	
	# TODO:Load behaviors from behavior_keys once Phase 2 is implemented
	# For now, uses default behaviors from BehaviorComponent._init()
	
	REG.add_component(uid, component)

func _add_animation_state(REG:REGISTRY, uid:int, overrides:Dictionary)->void:
	if not has_animation_state:
		return
	
	var component := AnimationStateComponent.new()
	# TODO:Apply animation_map once animation system supports custom mappings
	REG.add_component(uid, component)

func _add_information(REG:REGISTRY, uid:int, overrides:Dictionary)->void:
	if not has_information:
		return
	
	var name:String = overrides.get("display_name", display_name)
	var gen:String = overrides.get("gender", gender)
	var show:bool = overrides.get("show_ui", show_ui)
	
	var component := InformationComponent.new(name, gen, show)
	REG.add_component(uid, component)

func _add_actor(REG:REGISTRY, uid:int, overrides:Dictionary)->void:
	if not is_actor and not overrides.get("is_actor", false):
		return
	
	var component := ActorComponent.new(uid)
	REG.add_component(uid, component)
