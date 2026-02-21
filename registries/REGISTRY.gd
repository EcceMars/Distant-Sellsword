## REGISTRY.gd
## Accessor and store for all relevant data
extends Node

enum C_FLAGS {
	ANIM = BaseComponent.Flag.ANIMATION_STATE,
	BEHAV = BaseComponent.Flag.BEHAVIOR,
	INFO = BaseComponent.Flag.INFORMATION,
	ITEM = BaseComponent.Flag.ITEM,
	MEMORY = BaseComponent.Flag.MEMORY,
	MOVE = BaseComponent.Flag.MOVEMENT,
	STATS = BaseComponent.Flag.STATS,
	VISUAL = BaseComponent.Flag.VISUAL
	}

# World constants
var WIDTH:int = 32
var HEIGHT:int = 24
var SCALE:int = 16		## Grid/sprite scale
var MAX_ENTITIES:int = 64

## Delta accumulator
var DELTA:float = 0.0

## Deterministic accumulator (TEST: will this overflow?)
var tick:int = 0

## Next open unique id
var _open_uid:int = 0

## Unique id to list of [BaseComponent] bitmask signature
var ENTITIES:Dictionary[int, int] = {}
## [BaseComponent] registry by unique id: uid -> { [enum BaseComponent.Flag]: [BaseComponent] }.
## Use [method get_component] to access.
var COMPONENT_STORE:Dictionary[int, Dictionary] = {}

## All loaded systems.
var SYSTEMS:Dictionary[String, BaseSystem] = {}

## [ActionSystem]
var ACT:ActionSystem = null
# REGISTRIES
## [ArchetypeRegistry]
var AR_REG:ArchetypeRegistry = null
## [BehaviorRegistry]
var BE_REG:BehaviorRegistry = null
## [ItemRegistry]
var IT_REG:ItemRegistry = null
## [TerrainRegistry]
var TE_REG:TerrainRegistry = null
## [SpriteRegistry]
var SP_REG:SpriteRegistry = null
## [DATASTORE]
var DATA:DATASTORE = null

## [Node2D] responsible for holding visuals
var CANVAS:Node2D = null
var ENT_LAYER:Node2D = null
## Texture for holding biome data.
var TERRAIN:Node2D = null

func start(MAIN:Node, _data:DATASTORE, max_entities:int = MAX_ENTITIES, width:int = WIDTH, height:int = HEIGHT, scale:int = SCALE)->void:
	MAX_ENTITIES = max_entities
	CANVAS = CanvasScript.new()
	CANVAS.name = "CANVAS"
	CANVAS.y_sort_enabled = false
	
	DATA = _data
	
	MAIN.add_child(CANVAS)
	WIDTH = width
	HEIGHT = height
	SCALE = scale
	
	TERRAIN = Node2D.new()
	TERRAIN.name = "TERRAIN"
	TERRAIN.z_index = -1
	CANVAS.add_child(TERRAIN)
	
	ENT_LAYER = Node2D.new()
	ENT_LAYER.name = "ENTITIES"
	ENT_LAYER.y_sort_enabled = true
	CANVAS.add_child(ENT_LAYER)
	
	AR_REG = ArchetypeRegistry.new()
	BE_REG = BehaviorRegistry.new()
	IT_REG = ItemRegistry.new()
	TE_REG = TerrainRegistry.new()
	SP_REG = SpriteRegistry.new()

	for n:int in MAX_ENTITIES:
		ENTITIES[n] = 0
		COMPONENT_STORE[n] = {}
## Register a new entity.
## Returns -1 if registry is full.
func create_entity()->int:
	var uid:int = _request_uid()
	ENTITIES[uid] = 0
	COMPONENT_STORE[uid] = {}
	return uid
## Destroys an entity and removes all its components.
## Uses swap-and-pop pattern for O(1) removal.
func destroy_entity(uid:int)->void:
	if not _is_valid_entity(uid): return
	
	# Waits until VisualSytem deletes the sprite
	var visual_node_check:VisualComponent = get_component(uid, C_FLAGS.VISUAL)
	if visual_node_check and visual_node_check.sprite:
		return
	
	var item:ItemComponent = get_component(uid, C_FLAGS.ITEM)
	if item: IT_REG.unregister_item(uid)

	var last_uid:int = _open_uid - 1
	if uid != last_uid:
		ENTITIES[uid] = ENTITIES[last_uid]
		COMPONENT_STORE[uid] = COMPONENT_STORE[last_uid]
	ENTITIES.erase(last_uid)
	COMPONENT_STORE.erase(last_uid)
	_open_uid -= 1
## Starts [param system] and adds it to the [SYSTEMS].
func start_system(system:BaseSystem)->void:
	SYSTEMS[system.in_registry()] = system
## Update all systems at [SYSTEMS].
func update()->void:
	for system:BaseSystem in SYSTEMS.values(): system.process()
	tick += 1
	CANVAS.queue_redraw()
## Register [param component] to uid.
func add_component(uid:int, component:BaseComponent, override:bool = false)->BaseComponent:
	if not _is_valid_entity(uid): return null
	if not component or not component.flag: return null
	
	ENTITIES[uid] |= component.flag
	if not override and COMPONENT_STORE[uid].get(component.flag): return COMPONENT_STORE[uid][component.flag]
	COMPONENT_STORE[uid][component.flag] = component
	return COMPONENT_STORE[uid][component.flag]
## Undoes the entity|component register and deletes the component
func delete_component(uid:int, flag:int)->void:
	if not COMPONENT_STORE[uid].get(flag): return
	
	ENTITIES[uid] &= ~flag
	COMPONENT_STORE[uid].erase(flag)
## Gets all components for an entity.
func get_entity_components(uid:int)->Dictionary:
	if not _is_valid_entity(uid): return {}
	return COMPONENT_STORE[uid]
## For [BaseSystem] querying
func get_all_components_of(flag:int)->Array:
	var eligible: Array[int] = get_entities_by(flag)
	var result: Array = []
	for uid: int in eligible:
		if COMPONENT_STORE[uid].has(flag):
			result.append(COMPONENT_STORE[uid][flag])
	return result
## Query using a bitmask
func get_entities_by(bitmask:int)->Array[int]:
	var result:Array[int] = []
	for uid:int in _open_uid:
		if has_components(uid, bitmask):
			result.append(uid)
	return result
func get_component(uid:int, flag:int)->BaseComponent:
	if not _is_valid_entity(uid): return null
	return COMPONENT_STORE[uid].get(flag)
## For a more complete search use: BEHAVIOR | MOVEMENT (when checking for a list of components)
func has_components(uid:int, required_mask:int)->bool:
	if not _is_valid_entity(uid):
		return false
	return (ENTITIES[uid] & required_mask) == required_mask
func get_ent_position(uid:int)->Vector2:
	var mov_component:MovementComponent = REG.get_component(uid, C_FLAGS.MOVE)
	if not mov_component: return -Vector2.ONE
	return REG.get_component(uid, C_FLAGS.MOVE).get("position")
## Registers an unused unique id and returns it.
func _request_uid()->int:
	if _open_uid >= MAX_ENTITIES: return -1
	var uid:int = _open_uid
	_open_uid += 1
	return uid
## A check if entity ID is valid (0 : _open_uid).
func _is_valid_entity(uid:int)->bool:
	return uid in range(0, _open_uid) and ENTITIES.has(uid)
func _display_entity_info(uid:int)->bool:
	if not _is_valid_entity(uid): return false
	var components:Dictionary = get_entity_components(uid)
	var message:String = "%d:\n" % uid
	for type:BaseComponent.Flag in components:
		message += "\t" + str(type) + ": " + str(components[type]) + "\n"
	print(message)
	return true
