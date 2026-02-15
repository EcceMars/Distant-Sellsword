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
	
	REG.start_system(MovementSystem.new())
	REG.start_system(VisualSystem.new())
	REG.start_system(ActorSystem.new(REG))
	REG.start_system(BehaviorSystem.new())
	REG.start_system(InformationSystem.new(UI))
	REG.start_system(StatsSystem.new())
	REG.start_system(AnimationSystem.new())
	
	REG.get_system(ActorSystem).MOV_SYS = REG.get_system(MovementSystem)
	
	REG.CONSTRUCTOR.spawn_tree(REG)
	REG.CONSTRUCTOR.spawn_villager(REG)
	REG.CONSTRUCTOR.spawn_player(REG)
	
	REG.get_system(ActorSystem).scan_for_actors(REG)
func _process(delta:float)->void:
	if act_frame >= frame_len:
		act_frame = 0.0
		for system:BaseSystem in REG.SYSTEMS.values():
			system.process(REG)
	act_frame += delta
