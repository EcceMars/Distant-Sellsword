## ECS manager. The function process should be called to update the state of the world.
class_name ECS_MANAGER
extends RefCounted

var WIDTH:int = 0
var HEIGHT:int = 0
var POPULATION:int = 1

## All entities
var entities:Array[Entity] = []
## All components and entity's uids for entities that have them: component_type -> Array[UID]
var components:Dictionary[String, Array] = {}
## All systems to process the world
var systems:Dictionary[String, System] = {}

var dying_world:bool = false
var dead_ratio:float = 0

## Processes the next state of the world
func process()->void:
	for system:String in systems:
		var sys:System = systems[system]
		sys.process(self)
func get_all_with_component(component:Script)->Array:
	return components.get(component.get_global_name())
func _init(_population:int = 3, width:int = 50, height:int = 50)->void:
	POPULATION = _population
	WIDTH = width
	HEIGHT = height
	
	entities.clear()
	entities.resize(POPULATION)
	for n:int in POPULATION:
		entities[n] = Entity.new()
	
	for component in BaseComponent.REGISTRY:
		components[BaseComponent.REGISTRY[component]] = []
func spawn_entity(_components:Array[BaseComponent])->bool:
	# Find empty entity
	var entity:Entity = null
	var uid:int = 0
	for e:Entity in entities:
		if e.uid == -1:
			entity = e
			entity.uid = uid
			break
		uid += 1
		if uid > POPULATION:
			return false
			
	for component:BaseComponent in _components:
		extend_ent_component(entity, component)
	return true
func despawn_entity(entity:Entity)->void:
	for component_name in entity.components:
		var comp_array = components[component_name]
		var ent_comp = entity.components[component_name]
		ent_comp.clear()
		comp_array.erase(entity)
	entity.components.clear()
	entity.uid = -1
	dead_ratio += 1
	var living_tot:float = float(POPULATION)
	living_tot *= 0.4 - 0.1
	var ratio:float = float(dead_ratio) / living_tot
	dying_world = ratio > 0.7
func start_system(system:System)->void:
	systems[system.in_registry()] = system
func extend_ent_component(entity:Entity, component:BaseComponent, override:bool = false)->void:
	entity.add_component(component, override)
	var c_name:String = component.in_registry()
	if not components.get(c_name):
		components[c_name] = [entity]
	else:
		components[c_name].append(entity)
