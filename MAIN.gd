extends Node

const WIDTH:int = 200
const HEIGHT:int = 200

var WORLD:ECS_MANAGER

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
	hero.add_component(MovementComponent.new(h_pos, true, 1), true)
	hero.add_component(ControllerComponent.new(self, hero))
	hero.get_component(VisualComponent).is_static = false
	WORLD.start_system(MovementSystem.new())
	var visual_system:VisualSystem = VisualSystem.new()
	visual_system.instance(WORLD)
	WORLD.start_system(visual_system)
	var controller:ControllerSystem = ControllerSystem.new(WORLD, hero.get_component(ControllerComponent))
	WORLD.start_system(controller)
func _process(_delta:float)->void:
	for system:System in WORLD.systems:
		system.process(WORLD)
