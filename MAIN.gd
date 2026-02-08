extends Node

const POPULATION:int = 300
const FRAME_LEN:float = 0.03
const WIDTH:int = 800
const HEIGHT:int = 600

var WORLD:ECS_MANAGER
var START:bool = false
var frame:float = FRAME_LEN
var dead_count:int = 0

var visual_nodes:Array[Node] = []

func _ready()->void:
	generate()
func _process(_delta:float)->void:
	if not START: return
	if frame >= FRAME_LEN:
		for system:System in WORLD.systems.values():
			system.process(WORLD)
		frame = 0.0
	frame += _delta
	if WORLD.dying_world:
		START = false
		generate()
func generate()->void:
	if WORLD:
		START = false
		await get_tree().create_timer(3).timeout
		print("\n\n\n---------World is anew!---------\n\n\n")
		for node in visual_nodes:
			if node:
				node.queue_free()
		visual_nodes.clear()
		await get_tree().create_timer(3).timeout
	WORLD = null
	WORLD = ECS_MANAGER.new(POPULATION, WIDTH, HEIGHT)
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
	var h_visual:VisualComponent = hero.get_component(VisualComponent)
	h_visual.is_static = false
	h_visual.visual.color = Color.BLUE
	var health:HealthComponent = hero.get_component(HealthComponent)
	health.energy.regen_factor = 0.5
	
	for n in POPULATION * 0.4:
		var elected:Entity = WORLD.entities.pick_random()
		while elected == hero: elected = WORLD.entities.pick_random()
		
		var old_pos:Vector2 = elected.get_component(MovementComponent).position
		WORLD.extend_ent_component(elected, HealthComponent.new(), true)
		WORLD.extend_ent_component(elected, MovementComponent.new(old_pos, true), true)
		WORLD.extend_ent_component(elected, BehaviorComponent.new())
		var visual:VisualComponent = elected.get_component(VisualComponent)
		visual.is_static = false
		visual.visual.color = Color.RED
	
	WORLD.start_system(MovementSystem.new())
	var visual_system:VisualSystem = VisualSystem.new()
	visual_system.instance(WORLD)
	WORLD.start_system(visual_system)
	var controller:ControllerSystem = ControllerSystem.new(WORLD, hero.get_component(ControllerComponent))
	WORLD.start_system(controller)
	var health_sys:HealthSystem = HealthSystem.new()
	WORLD.start_system(health_sys)
	var behavior_sys:BehaviorSystem = BehaviorSystem.new()
	WORLD.start_system(behavior_sys)
	
	START = true
