## ECS manager. The function process should be called to update the state of the world.
class_name ECS_MANAGER
extends RefCounted

var WIDTH:int = 0
var HEIGHT:int = 0
var POPULATION:int = 0

## Empty entities
var entities:Array[Entity] = []
## All components and entity's uids for entities that have them: component_type -> Array[UID]
var components:Dictionary[String, Array] = {}
## All systems to process the world
var systems:Array[System] = []

## Processes the next state of the world
func process()->void:
	for system:System in systems:
		system.process(self)
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
		entity.add_component(component)
		components[component.in_registry()].append(entity)
	return true
func start_system(system:System)->void:
	systems.append(system)
