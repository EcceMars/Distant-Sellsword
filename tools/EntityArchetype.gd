## Base class for entity archetypes - blueprints for entity creation.
## Archetypes provide convenient defaults but don't restrict runtime modification.
## The ECS remains fully dynamic - components can be added/removed freely.
@icon("res://assets/img/icons/main_icon.png")
class_name EntityArchetype
extends Resource

## Human-readable archetype name
@export var archetype:String = "Unnamed"

## Visual configuration
@export_group("Visual")
@export var sprite_type:VisualComponent.SpriteType = VisualComponent.SpriteType.DEBUG
@export var anim_key:String = "idle"
@export var debug_col:Color = Color.PURPLE

## Movement configuration
@export_group("Movement")
@export var position:Vector2i = Vector2i(REG.WIDTH * 0.5, REG.HEIGHT * 0.5).snapped(Vector2i.ONE * REG.SCALE)
@export var moves:bool = true
@export var is_solid:bool = true
@export var can_be_pushed:bool = false		## Needs implementation
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
@export var has_animations:bool = false
## Custom animation mappings:AnimationStateComponent.State->animation_name
## If empty, uses default mappings from AnimationSystem
@export var animation_map:Dictionary = {}

## Information/UI configuration
@export_group("Information")
@export var has_information:bool = false
@export var char_name:String = ""
@export var gender:String = "Female"
@export var show_ui:bool = false

## Actor/Player control
@export_group("Input")
@export var is_actor:bool = false

## Creates an entity from this archetype.
## Returns the entity UID, or -1 on failure.
## [param position] - Spawn position (required if has_movement is true)
## [param overrides] - Dictionary for runtime overrides (e.g. {"char_name":"Bob"})
func create(overrides:Dictionary = {})->int:
	var uid:int = REG.create_entity()
	if uid == -1:
		push_error("[EntityArchetype] Registry full, cannot spawn %s" % archetype)
		return -1
	
	# Build components based on configuration
	_add_movement(uid, overrides)
	_add_visual(uid, overrides)
	_add_stats(uid, overrides)
	#_add_behavior(uid, overrides)
	_add_animation_state(uid, overrides)
	#_add_information(uid, overrides)
	_add_actor(uid, overrides)

	return uid
func _add_actor(uid:int, overrides:Dictionary)->void:
	if not is_actor and not overrides.get("is_actor", false):
		return
	
	
	var component:ActorComponent = ActorComponent.new(uid)
	REG.add_component(uid, component)
func _add_animation_state(uid:int, overrides:Dictionary)->void:
	if not has_animations:
		return
	
	var component:AnimationStateComponent = AnimationStateComponent.new()
	# TODO:Apply animation_map once animation system supports custom mappings
	REG.add_component(uid, component)
## Override this in subclasses for custom component logic
func _add_movement(uid:int, overrides:Dictionary)->void:
	position = overrides.get("position", REG.AR_REG.random_position())
	is_solid = overrides.get("is_solid", is_solid)
	moves = overrides.get("moves", moves)
	movement_type = overrides.get("movement_type", movement_type)
	movement_speed = overrides.get("movement_speed", movement_speed)
	
	var component:MovementComponent = MovementComponent.new(position, is_solid, moves, movement_type, movement_speed)
	REG.add_component(uid, component)
func _add_visual(uid:int, overrides:Dictionary)->void:
	var spr_type:VisualComponent.SpriteType = overrides.get("sprite_type", sprite_type)
	var spr_key:String = overrides.get("anim_key", anim_key)
	var spr_pos:Vector2i = overrides.get("position", Vector2i(REG.AR_REG.random_position()))
	var color:Color = overrides.get("debug_color", debug_col)
	
	var component:VisualComponent = VisualComponent.new(spr_type, spr_key, spr_pos, color)
	REG.add_component(uid, component)

func _add_stats(uid:int, overrides:Dictionary)->void:
	if not has_stats:
		return

	var component:StatsComponent = StatsComponent.new(
		overrides.get("char_name", char_name),
		overrides.get("gender", gender),
		
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
