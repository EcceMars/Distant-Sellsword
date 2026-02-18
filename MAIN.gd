extends Node

@export var CAM_ANCHOR:CAMERA_MANAGER = null
@export var FRAME_LEN:float = 0.05
var frame:float = FRAME_LEN

func _ready()->void:
	REG.start(self)
	
	REG.start_system(MovementSystem.new())
	REG.start_system(VisualSystem.new())
	REG.start_system(StatsSystem.new())
	REG.start_system(AnimationSystem.new())
	REG.start_system(InputSystem.new())
	
	REG.AR_REG.register_entity("villager")
	REG.AR_REG.register_entity("berries")
	REG.AR_REG.register_entity("duck")
	var player_uid:int = REG.AR_REG.register_entity("actor")
	REG.AR_REG.register_entity("tree")
	
	CAM_ANCHOR.start(REG.get_component(player_uid, REG.C_FLAGS.MOVE).grid_posi)
	CAM_ANCHOR.follow_uid = player_uid

func _process(delta:float)->void:
	REG.DELTA = delta
	REG.update()
	CAM_ANCHOR.process(delta)
