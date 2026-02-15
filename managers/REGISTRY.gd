## Accessor and store for all relevant data ([Object] as this should always be live).
## This object acts as the world for the ECS
class_name REGISTRY
extends Object

var WIDTH:int = 32
var HEIGHT:int = 24
var SCALE:int = 16

## UID (unique id) to list of [BaseComponent] bitmask signature
var ENTITIES:Dictionary[int, int] = {}
## [BaseComponent] by UID -> { [enum BaseComponent.Flag]: [BaseComponent] }
var COMPONENT_STORE:Dictionary[int, Dictionary] = {}
## Quick reference for all entities with a certain [enum BaseComponent.Flag]
var ENTITY_COMPONENT_REGISTRY:Dictionary[int, Array] = {}
## Collection of systems
var SYSTEMS:Dictionary[String, BaseSystem] = {}

## [Node2D] responsible for holding [VisualComponent] sprites
var CANVAS:Node2D = null
## List of [CANVAS] node
var visual_nodes:Array[Node] = []

var MAX_ENTITIES:int = 64
## Next open unique id
var _open_uid:int = 0

func _init(max_entities:int = MAX_ENTITIES, canvas:Node2D = CANVAS, width:int = WIDTH, height:int = HEIGHT, scale:int = SCALE)->void:
	MAX_ENTITIES = max_entities
	CANVAS = canvas
	WIDTH = width
	HEIGHT = height
	SCALE = scale
	
	for n:int in MAX_ENTITIES:
		ENTITIES[n] = 0
		COMPONENT_STORE[n] = {}
	for flag:BaseComponent.Flag in BaseComponent.Flag.values():
		ENTITY_COMPONENT_REGISTRY[flag] = []
	for sys:Script in BaseSystem.TYPES:
		SYSTEMS[BaseSystem.TYPES[sys]] = null
	
	#print(ENTITIES)
	#print(COMPONENT_STORE)
	#print(ENTITY_COMPONENT_REGISTRY)
	#print(SYSTEMS)
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
	
	# Get the last entity's data
	var last_uid:int = _open_uid - 1
	
	if uid != last_uid:
		# Move last entity's data to the deleted entity's slot
		ENTITIES[uid] = ENTITIES[last_uid]
		COMPONENT_STORE[uid] = COMPONENT_STORE[last_uid]
		
		# Update all component registries for the moved entity
		for flag in COMPONENT_STORE[uid].keys():
			# Remove old reference and add new one
			ENTITY_COMPONENT_REGISTRY[flag].erase(last_uid)
			ENTITY_COMPONENT_REGISTRY[flag].append(uid)
	
	# Clean up the last entity
	ENTITIES.erase(last_uid)
	COMPONENT_STORE.erase(last_uid)
	_open_uid -= 1
## Register [param component] to uid.
func add_component(uid:int, component:BaseComponent, override:bool = false)->BaseComponent:
	if not _is_valid_entity(uid): return null
	if not component or not component.flag: return null

	ENTITIES[uid] |= component.flag
	
	if not ENTITY_COMPONENT_REGISTRY.has(component.flag):
		ENTITY_COMPONENT_REGISTRY[component.flag] = []

	if not override and uid in ENTITY_COMPONENT_REGISTRY[component.flag]: return null
	
	COMPONENT_STORE[uid][component.flag] = component
	ENTITY_COMPONENT_REGISTRY[component.flag] += [uid]
	return COMPONENT_STORE[uid][component.flag]
## Undoes the entity|component register and deletes the component
func delete_component(uid:int, flag:int)->void:
	if not COMPONENT_STORE[uid].get(flag): return
	
	ENTITIES[uid] &= ~flag
	COMPONENT_STORE[uid].erase(flag)
	ENTITY_COMPONENT_REGISTRY[flag].erase(uid)
## Registers an unused unique id and returns it.
func _request_uid()->int:
	if _open_uid >= MAX_ENTITIES: return -1
	var uid:int = _open_uid
	_open_uid += 1
	return uid
## A check if entity ID is valid (0 : _open_uid).
func _is_valid_entity(uid:int)->bool:
	return uid in range(0, _open_uid) and ENTITIES.has(uid)
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
## For a more complete search use: ACTOR | MOVEMENT (when checking for a list of components)
func has_components(uid:int, required_mask:int)->bool:
	if not _is_valid_entity(uid):
		return false
	return (ENTITIES[uid] & required_mask) == required_mask
func start_system(system:BaseSystem)->void:
	SYSTEMS[system.in_registry()] = system
## Returns a system
func get_system(system:Script)->BaseSystem:
	return SYSTEMS.get(system.get_global_name())
## Reference for quick build of entities
class CONSTRUCTOR:
	static func spawn_player(REG:REGISTRY)->int:
		var uid:int = REG.create_entity()
		var mov_component:MovementComponent = MovementComponent.new(rand_vec2(REG), true, true, 1, 5)
		var vis_component:VisualComponent = VisualComponent.new(
			REG,
			VisualComponent.SpriteType.ANIMATED,
			"m_knight")
		var act_component:ActorComponent = ActorComponent.new(uid)
		var stats_component:StatsComponent = StatsComponent.new()
		var info_component:InformationComponent = InformationComponent.new("Iphrit", "Male", true)
		var a_state_component:AnimationStateComponent = AnimationStateComponent.new()
		
		REG.add_component(uid, mov_component)
		REG.add_component(uid, vis_component)
		REG.add_component(uid, act_component)
		REG.add_component(uid, stats_component)
		REG.add_component(uid, info_component)
		REG.add_component(uid, a_state_component)

		return uid
	static func spawn_tree(REG:REGISTRY)->int:
		var uid:int = REG.create_entity()
		var mov_component:MovementComponent = MovementComponent.new(rand_vec2(REG))
		var vis_component:VisualComponent = VisualComponent.new(
			REG,
			VisualComponent.SpriteType.ANIMATED,
			"pine_tree")
			
		REG.add_component(uid, mov_component)
		REG.add_component(uid, vis_component)
		
		return uid
	static func spawn_villager(REG:REGISTRY)->int:
		var uid:int = REG.create_entity()
		var mov_component:MovementComponent = MovementComponent.new(rand_vec2(REG), true, true, 1, 5)
		var vis_component:VisualComponent = VisualComponent.new(
			REG, VisualComponent.SpriteType.ANIMATED,
			"f_human")
		var behavior_component:BehaviorComponent = BehaviorComponent.new()
		var stats_component:StatsComponent = StatsComponent.new()
		var info_component:InformationComponent = InformationComponent.new(["Rita", "Elya", "Randa"].pick_random(), "Female", true)
		var a_state_component:AnimationStateComponent = AnimationStateComponent.new()
		
		REG.add_component(uid, mov_component)
		REG.add_component(uid, vis_component)
		REG.add_component(uid, behavior_component)
		REG.add_component(uid, stats_component)
		REG.add_component(uid, info_component)
		REG.add_component(uid, a_state_component)

		return uid
	
	static func rand_vec2(REG:REGISTRY)->Vector2:
		return Vector2(
			randi() % REG.WIDTH * REG.SCALE,
			randi() % REG.HEIGHT * REG.SCALE
		)
