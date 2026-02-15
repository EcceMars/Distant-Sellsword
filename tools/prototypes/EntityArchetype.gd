@icon("res://assets/img/icons/main_icon.png")
## Base class for entity archetypes - blueprints for entity creation.
class_name EntityArchetype
extends Resource

@export var archetype:String = "Unknown"

## Visuals
@export_group("Visual")
@export var is_visible:bool = false
@export var sprite_type:VisualComponent.SpriteType = VisualComponent.SpriteType.DEBUG
@export var anim_key:String = ""

## Movement
@export_group("Movement")
@export var has_position:bool = false	## Whether this entity has a position in the world (e.g. an item may be stored on an inventory and not be in the world).
@export var is_solid:bool = false		## Whether this entity blocks others' movement.
@export var moves:bool = false			## Whether this entity can move on its own.
@export var mov_type:MovementComponent.Movable.Flag = MovementComponent.Movable.Flag.GROUND
@export var mov_speed:float = 1.0

## Stats
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

## AI
@export_group("Behavior")
@export var has_ai:bool = false
@export var behavior_keys:Array[String] = [] ## Array of behavior resources.

## Animations
@export_group("Animation")
@export var has_animations:bool = false
## Animation mapping.
## If empty, uses default mappings from AnimationSystem.
@export var animation_map:Dictionary = {}

## Information/UI
@export_group("Information")
@export var has_information:bool = false
@export var display_name:String = ""
@export var gender:String = "Female"
@export var show_ui:bool = false

## Actor control
@export_group("Control")
@export var is_actor:bool = false

## Creates an entity from this archetype.
## Returns the entity UID, or -1 on failure.
## [param position] - Spawn position (required if has_movement is true)
## [param overrides] - Dictionary for runtime overrides)
func spawn(REG:REGISTRY, position:Vector2, overrides:Dictionary = {}) -> int:
	var uid:int = REG.create_entity()
	if uid < 0: return -1
	_add_movement(REG, uid, position, overrides)
	_add_visual(REG, uid, overrides)
	_add_stats(REG, uid, overrides)
	_add_behavior(REG, uid, overrides)
	_add_animation_state(REG, uid, overrides)
	_add_information(REG, uid, overrides)
	_add_actor(REG, uid, overrides)
	return uid
func _add_movement(REG:REGISTRY, uid:int, position:Vector2, overrides:Dictionary)->void:
	if not has_position: return
	position = overrides.get("position", position)
	is_solid = overrides.get("is_solid", is_solid)
	moves = overrides.get("moves", moves)
	mov_type = overrides.get("mov_type", mov_type)
	mov_speed = overrides.get("mov_speed", mov_speed)
	var mov_component:MovementComponent = MovementComponent.new(position, is_solid, moves, mov_type, mov_speed)
	REG.add_component(uid, mov_component)
func _add_visual(REG:REGISTRY, uid:int, overrides:Dictionary)->void:
	if not is_visible: return
	sprite_type = overrides.get("sprite_type", sprite_type)
	anim_key = overrides.get("anim_key", anim_key)
	var visual_component:VisualComponent = VisualComponent.new(REG, sprite_type, anim_key)
	REG.add_component(uid, visual_component)
func _add_stats(REG:REGISTRY, uid:int, overrides:Dictionary)->void:
	if not has_stats: return

	var stats_component:StatsComponent = StatsComponent.new(
		overrides.get("blood_max", blood_max),
		overrides.get("blood_regen", blood_regen),
		overrides.get("energy_max", energy_max),
		overrides.get("energy_regen", energy_regen),
		overrides.get("hunger_max", hunger_max),
		overrides.get("hunger_regen", hunger_regen),
		overrides.get("thirst_max", thirst_max),
		overrides.get("thirst_regen", thirst_regen)
	)
	REG.add_component(uid, stats_component)
func _add_behavior(REG:REGISTRY, uid:int, overrides:Dictionary)->void:
	if not has_ai: return

	behavior_keys = overrides.get("behavior_keys", self.behavior_keys)
	var behavior_component:BehaviorComponent = BehaviorComponent.new(behavior_keys)
	REG.add_component(uid, behavior_component)
func _add_animation_state(REG:REGISTRY, uid:int, overrides:Dictionary)->void:
	if not has_animations:
		return
	
	var component:AnimationStateComponent = AnimationStateComponent.new()
	# TODO: Apply animation_map once animation system supports custom mappings
	REG.add_component(uid, component)
func _add_information(REG: REGISTRY, uid: int, overrides: Dictionary) -> void:
	if not has_information:
		return
	
	display_name = overrides.get("display_name", display_name)
	gender = overrides.get("gender", gender)
	show_ui = overrides.get("show_ui", show_ui)
	
	var component:InformationComponent = InformationComponent.new(display_name, gender, show_ui)
	REG.add_component(uid, component)
func _add_actor(REG: REGISTRY, uid: int, overrides: Dictionary) -> void:
	if not is_actor and not overrides.get("is_actor", false): return
	
	var component:ActorComponent = ActorComponent.new(uid)
	REG.add_component(uid, component)
