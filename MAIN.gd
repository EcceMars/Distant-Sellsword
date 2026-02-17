extends Node

@export var CAM:Camera2D
@export var FRAME_LEN:float = 0.05
var frame:float = FRAME_LEN

func _ready()->void:
	REG.start(self)
	
	REG.start_system(MovementSystem.new())
	REG.start_system(VisualSystem.new())
	REG.start_system(StatsSystem.new())
	REG.start_system(AnimationSystem.new())
	REG.start_system(ActorSystem.new(CAM))		# Player input logic goes here
	
	REG.AR_REG.register_entity("villager")
	REG.AR_REG.register_entity("berries")
	REG.AR_REG.register_entity("duck")
	REG.AR_REG.register_entity("actor")
	REG.AR_REG.register_entity("tree")

func _process(delta:float)->void:
	REG.DELTA = delta
	REG.update()
	
	
	#if frame >= FRAME_LEN:
		#REG.update()
		#frame = 0.0
	#frame += delta
