extends Node

const WIDTH:int = 200
const HEIGHT:int = 200

var WORLD:ECS_MANAGER
var START:bool = false

func _ready()->void:
	WORLD = ECS_MANAGER.new(7, WIDTH, HEIGHT)
	for pop in WORLD.POPULATION:
		var pos:Vector2 = Vector2(randi() % WIDTH, randi() % HEIGHT)
		WORLD.spawn_entity(
			[
				MovementComponent.new(pos),
				VisualComponent.new(self)
			]
		)
	var hero:Entity = WORLD.entities.pick_random()
	var h_pos:Vector2 = hero.get_component(MovementComponent).position
	WORLD.extend_ent_component(hero, MovementComponent.new(h_pos, true, 1), true)
	WORLD.extend_ent_component(hero, ControllerComponent.new(self, hero))
	WORLD.extend_ent_component(hero, HealthComponent.new(), true)
	hero.get_component(VisualComponent).is_static = false
	var health:HealthComponent = hero.get_component(HealthComponent)
	health.energy.regen_factor = 0.5
	WORLD.start_system(MovementSystem.new())
	var visual_system:VisualSystem = VisualSystem.new()
	visual_system.instance(WORLD)
	WORLD.start_system(visual_system)
	var controller:ControllerSystem = ControllerSystem.new(WORLD, hero.get_component(ControllerComponent))
	WORLD.start_system(controller)
	var health_sys:HealthSystem = HealthSystem.new()
	WORLD.start_system(health_sys)
	
	START = true
func _process(_delta:float)->void:
	if not START: return
	for system:System in WORLD.systems:
		system.process(WORLD)
