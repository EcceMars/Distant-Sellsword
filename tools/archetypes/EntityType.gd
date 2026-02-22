## Base blueprint for all entity archetypes.
## Subtypes populate [member data] in [method _init] and optionally
## override [method _prepare] for runtime variation.
@icon("res://assets/img/icons/entity_icon.png")
class_name EntityType
extends Resource

## Defines if the sprite's texture is animated or just a sequence of states.
## In any case, sprite_res is supposed to be a [SpritesFrame].
enum SPRITE_TYPE {
	STATIC,			## Each frame is a state of the entity (a stone may have a normal state, or a cracked/break state)
	ANIMATED		## The [SpritesFrame] is animated.
	}

## Human-readable label.
@export var label:String = "Unnamed"
@export var sprite_icon:Texture2D
## Configuration container. Subtypes populate this in [method _init].
@export_custom(PROPERTY_HINT_RESOURCE_TYPE, "EntityData") var data:EntityData

## Called at the start of [method _build], before any component is added.
## Override for randomisation or conditional defaults (e.g. random name, sprite variant).
func _prepare()->void: pass

## Called at the end of [method _build], after all standard components.
## Override for extra components (e.g. [ItemComponent]).
func _post_build(_uid:int)->void: pass

## Assembles a new entity from [member data] at a random valid position.
## Returns the new entity UID, or -1 on failure.
func _build(spawn_position:Vector2 = -Vector2.ONE)->int:
	#_prepare()
	var uid:int = REG.create_entity()
	if uid == -1:
		push_error("[EntityType] Registry full, cannot spawn: %s" % label)
		return -1
	var position:Vector2 = spawn_position if spawn_position != -Vector2.ONE else _random_position()

	_add_movement(uid, position)
	_add_visual(uid, position)
	if data.has_stats:					_add_stats(uid)
	if data.has_animations:				_add_animation_state(uid)
	if data.behavior_keys.size() > 0:	_add_behavior(uid)
	if data.has_information:			_add_information(uid)
	if data.has_memory:					_add_memory(uid)
	if data.is_item:					_add_item_condition(uid, data.item_class, position)

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
			push_warning("[EntityType] Behavior '%s' not found — '%s' may need configuration." % [key, label])
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
func _add_item_condition(uid:int, item_class:ITEMSTORE.ItemClass, spawn_position:Vector2 = -Vector2.ONE)->void:
	var item_component:ItemComponent = ItemComponent.new(item_class)
	if not item_component: return
	
	item_component.world_position = spawn_position
	REG.add_component(uid, item_component)
	REG.IT_REG.register_item(uid, item_component)
## Returns a random unoccupied world position snapped to the grid.
## Falls back to [constant Vector2.ZERO] after 16 failed attempts.
func _random_position()->Vector2:
	var mov_sys:MovementSystem = REG.SYSTEMS.get("MovementSystem")
	var candidate:Vector2 = REG.TE_REG.random_position_for(data.move_type)
	if mov_sys and mov_sys.blocked_positions.has(Vector2i(candidate)):
		return REG.TE_REG.random_position_for(data.move_type)  ## One retry
	return candidate
func _to_string()->String:
	return get_script().get_global_name()
