extends Node

@export var _DATA_REG:DATASTORE = null

@export var CAM_ANCHOR:CAMERA_MANAGER = null
@export var UI:Control = null

@export var MAX_ENTITIES:int = 128

@export var WIDTH:int = 32
@export var HEIGHT:int = 24
@export var SCALE:int = 16

## Fixed simulation step length in seconds.
const FRAME_LEN:float = 5
#var _frame:float = FRAME_LEN

## How often (in seconds) the world tries to spawn a berry near a tree.
const BERRY_INTERVAL:float = 6.0
var _berry_timer:float = BERRY_INTERVAL

func _ready()->void:
	REG.start(self, _DATA_REG, MAX_ENTITIES, WIDTH, HEIGHT, SCALE)

	REG.start_system(MovementSystem.new())
	REG.start_system(VisualSystem.new())
	REG.start_system(StatsSystem.new())
	REG.start_system(AnimationSystem.new())
	REG.start_system(InputSystem.new())
	REG.start_system(BehaviorSystem.new())
	REG.start_system(BTreeSystem.new())
	REG.start_system(ActionSystem.new())
	REG.start_system(InformationSystem.new(UI))
	
	REG.get_system(InformationSystem).instance()
	REG.ACT = REG.get_system(ActionSystem)

	## Spawn world entities
	for _i:int in 16: REG.AR_REG.spawn(ENTITYSTORE.TYPES.TREE, "PineType")
	#for _i:int in 4:  REG.AR_REG.spawn(ENTITYSTORE.TYPES.VILLAGER, "F_WoodcutterType")
	#for _i:int in 4:  REG.AR_REG.spawn(ENTITYSTORE.TYPES.DUCK, "DuckType")
	for _i:int in 8:  REG.AR_REG.spawn(ENTITYSTORE.TYPES.BERRY, ["BlueBerryType", "RedBerryType"].pick_random())

	#var player_uid:int = REG.AR_REG.spawn(ENTITYSTORE.TYPES.ACTOR, "ActorType")
	var rita_uid:int = REG.AR_REG.spawn(ENTITYSTORE.TYPES.VILLAGER, "BTRitaType")
	CAM_ANCHOR.start(REG.get_ent_position(rita_uid))
	CAM_ANCHOR.follow_uid = rita_uid

func _process(delta:float)->void:
	REG.DELTA = delta
	REG.update()
	CAM_ANCHOR.process(delta)
	_try_spawn_berry(delta)

## Periodically spawns a berry near a random tree to keep the world fed.
func _try_spawn_berry(delta:float)->void:
	_berry_timer -= delta
	if _berry_timer > 0.0:
		return
	_berry_timer = BERRY_INTERVAL

	# Find all tree entities
	var trees:Array[int] = REG.get_entities_by(BaseComponent.Flag.MOVEMENT)
	trees = trees.filter(func(uid:int)->bool:
		var mov:MovementComponent = REG.get_component(uid, BaseComponent.Flag.MOVEMENT)
		# Trees are solid and non-moving — use as a rough filter
		return mov and not mov.movable and mov.solid
	)
	if trees.is_empty():
		return

	# Pick a random tree and spawn a berry nearby
	var tree_uid:int = trees.pick_random()
	var tree_pos:Vector2 = REG.get_ent_position(tree_uid)
	var offset:Vector2 = Vector2(
		float(randi_range(-2, 2)) * REG.SCALE,
		float(randi_range(-2, 2)) * REG.SCALE
	)
	var spawn_pos:Vector2 = tree_pos + offset
	spawn_pos = spawn_pos.clamp(Vector2.ZERO, Vector2(WIDTH -1, HEIGHT -1) * SCALE)
	
	var berry_uid:int = REG.AR_REG.spawn(ENTITYSTORE.TYPES.BERRY, ["BlueBerryType", "RedBerryType"].pick_random(), spawn_pos)
	if berry_uid == -1:
		return
