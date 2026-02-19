## Base blueprint for all entity archetypes.
## Subtypes populate [member data] in [method _init] and optionally
## override [method _prepare] for runtime variation.
@icon("res://assets/img/icons/main_icon.png")
class_name EntityArchetype
extends Resource

## Human-readable label, set in each subtype's [method _init].
var label:String = "Unnamed"
## Configuration container. Subtypes populate this in [method _init].
var data:Data = Data.new()

## Populates [member data] with archetype defaults.
## Always override in subtypes.
func _init()->void: pass

## Called at the start of [method _build], before any component is added.
## Override for randomisation or conditional defaults (e.g. random name, sprite variant).
func _prepare()->void: pass

## Called at the end of [method _build], after all standard components.
## Override for extra components (e.g. [ItemComponent]).
func _post_build(_uid:int)->void: pass

## Assembles a new entity from [member data] at a random valid position.
## Returns the new entity UID, or -1 on failure.
func _build(spawn_position:Vector2 = -Vector2.ONE)->int:
	_prepare()
	var uid:int = REG.create_entity()
	if uid == -1:
		push_error("[EntityArchetype] Registry full, cannot spawn: %s" % label)
		return -1
	
	var position:Vector2 = spawn_position \
		if spawn_position != -Vector2.ONE \
		else _random_position()
	
	_add_movement(uid, position)
	_add_visual(uid, position)
	if data.has_stats:					_add_stats(uid)
	if data.has_animations:				_add_animation_state(uid)
	if data.behavior_keys.size() > 0:	_add_behavior(uid)
	if data.has_information:			_add_information(uid)
	if data.has_memory:					_add_memory(uid)
	if data.is_item:					_add_item_condition(uid, data.item_type)

	_post_build(uid)
	return uid

## Adds a [MovementComponent] to [param uid].
func _add_movement(uid:int, position:Vector2)->void:
	REG.add_component(uid, MovementComponent.new(
		position,
		data.is_solid,
		data.moves,
		data.move_type,
		data.move_speed
	))

## Adds a [VisualComponent] to [param uid].
func _add_visual(uid:int, position:Vector2)->void:
	REG.add_component(uid, VisualComponent.new(
		data.sprite_type,
		data.sprite_key,
		Vector2i(position),
		data.debug_color
	))

## Adds a [StatsComponent] to [param uid].
func _add_stats(uid:int)->void:
	REG.add_component(uid, StatsComponent.new(
		data.char_name,
		data.gender,
		data.blood_max,   data.blood_regen,
		data.energy_max,  data.energy_regen,
		data.hunger_max,  data.hunger_regen,
		data.thirst_max,  data.thirst_regen
	))

## Adds an [AnimationStateComponent] to [param uid].
func _add_animation_state(uid:int)->void:
	REG.add_component(uid, AnimationStateComponent.new())

## Adds a [BehaviorComponent] to [param uid].
## Warns if any key in [member Data.behavior_keys] is not registered in [BehaviorRegistry].
func _add_behavior(uid:int)->void:
	for key:BaseBehavior.Type in data.behavior_keys:
		if not REG.BE_REG.has_behavior(uid, key):
			push_warning("[EntityArchetype] Behavior '%s' not found — '%s' may need configuration." % [key, label])
	REG.add_component(uid, BehaviorComponent.new(data.behavior_keys))

# TODO: implement InformationComponent
## Adds an [InformationComponent] to [param uid].
func _add_information(uid:int)->void:
	REG.add_component(uid, InformationComponent.new(data.char_name, "Female", false))
## Adds a [MemoryComponent] to [param uid] using archetype-level vision parameters.
func _add_memory(uid: int) -> void:
	REG.add_component(uid, MemoryComponent.new(
		data.memory_focus_limit,
		data.vision_range,
		data.vision_width
	))
func _add_item_condition(uid:int, item_type:String)->void:
	REG.add_component(uid, ItemComponent.new(item_type))
## Returns a random unoccupied world position snapped to the grid.
## Falls back to [constant Vector2.ZERO] after 16 failed attempts.
func _random_position()->Vector2:
	var mov_sys:MovementSystem = REG.SYSTEMS.get("MovementSystem")
	var attempts:int = 16
	while attempts > 0:
		var x:float = float(randi_range(0, REG.WIDTH - 1)) * REG.SCALE
		var y:float = float(randi_range(0, REG.HEIGHT - 1)) * REG.SCALE
		var candidate:Vector2 = Vector2(x, y)
		if mov_sys and mov_sys.blocked_positions.has(Vector2i(candidate)):
			attempts -= 1
			continue
		return candidate
	push_warning("[EntityArchetype] No free position found for '%s', spawning at origin." % label)
	return Vector2.ZERO
## All configuration data for a single archetype.
## Members are read by [method _build] to assemble components.
class Data:
	## Visual
	var sprite_type:VisualComponent.SpriteType = VisualComponent.SpriteType.DEBUG
	var sprite_key:String = ""
	var debug_color:Color = Color.PURPLE
	## Movement — position is assigned at build time
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
	var behavior_keys:Array[BaseBehavior.Type] = []
	## Flags
	var has_animations:bool = false
	var has_information:bool = false
	var has_memory:bool = false
	var is_item:bool = false
	## Memory
	var memory_focus_limit:int = 8
	var vision_range:float = 5.0 * REG.SCALE
	var vision_width:float = 2.0 * REG.SCALE
	## Item
	var item_type:String = "Generic"
