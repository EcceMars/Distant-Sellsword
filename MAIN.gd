extends Node

@export var CAM_ANCHOR:CAMERA_MANAGER = null

## Fixed simulation step length in seconds.
const FRAME_LEN:float = 0.05
var _frame:float = FRAME_LEN

## How often (in seconds) the world tries to spawn a berry near a tree.
const BERRY_INTERVAL:float = 10.0
var _berry_timer:float = BERRY_INTERVAL

func _ready()->void:
	REG.start(self)

	REG.start_system(MovementSystem.new())
	REG.start_system(VisualSystem.new())
	REG.start_system(StatsSystem.new())
	REG.start_system(AnimationSystem.new())
	REG.start_system(InputSystem.new())

	# Spawn world entities
	for _i:int in 8:  REG.AR_REG.spawn(ArchetypeRegistry.Type.TREE)
	for _i:int in 4:  REG.AR_REG.spawn(ArchetypeRegistry.Type.VILLAGER)
	for _i:int in 3:  REG.AR_REG.spawn(ArchetypeRegistry.Type.DUCK)
	for _i:int in 4:  REG.AR_REG.spawn(ArchetypeRegistry.Type.BERRY)

	var player_uid:int = REG.AR_REG.spawn(ArchetypeRegistry.Type.ACTOR)

	CAM_ANCHOR.start(REG.get_ent_position(player_uid))
	CAM_ANCHOR.follow_uid = player_uid
	
	print(REG._display_entity_info(player_uid))

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
	var berry_uid:int = REG.AR_REG.spawn(ArchetypeRegistry.Type.BERRY)
	if berry_uid == -1:
		return

	# Reposition the berry to be near the tree
	var b_mov:MovementComponent = REG.get_component(berry_uid, BaseComponent.Flag.MOVEMENT)
	if b_mov:
		b_mov.position = tree_pos + offset
		b_mov.grid_posi = Vector2i(b_mov.position).snappedi(REG.SCALE)
