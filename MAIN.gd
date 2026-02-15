extends Node
@onready var UI:Control = $UI

const MAX_ENTITIES:int = 320
const WIDTH:int = 32
const HEIGHT:int = 24
const SCALE:int = 16

var REG:REGISTRY = null
var frame_len:float = 0.03
var act_frame:float = frame_len

func _ready() -> void:
	var CANVAS:Node2D = Node2D.new()
	CANVAS.name = "CANVAS"
	CANVAS.y_sort_enabled = true
	add_child(CANVAS)
	REG = REGISTRY.new(MAX_ENTITIES, CANVAS, WIDTH, HEIGHT, SCALE)
	
	# Initialize systems
	REG.start_system(MovementSystem.new())
	REG.start_system(VisualSystem.new())
	REG.start_system(ActorSystem.new(REG))
	REG.start_system(BehaviorSystem.new())
	REG.start_system(InformationSystem.new(UI))
	REG.start_system(StatsSystem.new())
	REG.start_system(AnimationSystem.new())
	
	REG.get_system(ActorSystem).MOV_SYS = REG.get_system(MovementSystem)
	
	_spawn_initial_entities()
	
	REG.get_system(ActorSystem).scan_for_actors(REG)

## Spawn starting entities using the new archetype system
func _spawn_initial_entities() -> void:
	# Spawn some trees
	for i in range(3):
		REG.spawn_tree()
	
	# Spawn villagers
	for i in range(2):
		REG.spawn_villager()
	
	# Spawn player
	var player_uid:int = REG.spawn_player()
	print(REG.get_entity_components(player_uid))

func _process(delta:float)->void:
	if act_frame >= frame_len:
		act_frame = 0.0
		for system:BaseSystem in REG.SYSTEMS.values():
			system.process(REG)
	act_frame += delta
