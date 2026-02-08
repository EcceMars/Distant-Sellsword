class_name BehaviorSystem
extends System

const State:BehaviorComponent.State = BehaviorComponent.State

var think_interval:int = 60
var counter:int = think_interval

func process(world:ECS_MANAGER)->void:
	counter += 1
	if counter >= think_interval:
		for entity:Entity in world.get_all_with_component(BehaviorComponent):
			var behavior:BehaviorComponent = entity.get_component(BehaviorComponent)
			var health:HealthComponent = entity.get_component(HealthComponent)
			var movement:MovementComponent = entity.get_component(MovementComponent)
			if null in [behavior, health, movement]: continue
			
			if health.is_alive:
				update(behavior, health)
				act(entity, behavior, health, movement, world)
		counter = 0
	
func update(behavior:BehaviorComponent, health:HealthComponent)->void:
	if not health.is_conscious:
		behavior.current = State.REST
		return
	
	# Priority: dying > tired > hungry > wander
	if health.blood.ratio() < behavior.dying:
		behavior.current = State.FLEE
	elif health.energy.ratio() < behavior.tired:
		behavior.current = State.REST
	elif health.hunger.ratio() < behavior.hungry:
		behavior.current = State.SEEK_FOOD
	else:
		behavior.current = [State.WANDER, State.IDLE].pick_random()
func act(entity:Entity, behavior:BehaviorComponent, health:HealthComponent, movement:MovementComponent, world:ECS_MANAGER)->void:
	match behavior.current:
		State.WANDER:
			wander(entity, movement, world)
		State.REST:
			rest(movement, health)
		State.FLEE:
			flee(entity, movement, world)
		State.SEEK_FOOD:
			seek(entity, world)
		State.IDLE:
			idle(movement)
func idle(movement:MovementComponent)->void:
	print("Someone at " + str(movement.position) + " is idlying about...")
	if movement.movable.has_target:
		movement.clear_path()
## Entity periodically wanders about
func wander(entity:Entity, movement:MovementComponent, world:ECS_MANAGER)->void:
	print("%d wanders..." % entity.uid)
	if movement.movable or not movement.movable.has_target or counter % think_interval == 0:
		var target:Vector2 = movement.position + (movement.position * movement.movable.speed) * sign(randi_range(-1, 1))
		target = target.clamp(Vector2.ZERO, Vector2(world.WIDTH, world.HEIGHT))
		var mov_sys:MovementSystem = world.systems[in_registry(MovementSystem)]
		mov_sys.force_move(entity, target)
func rest(movement:MovementComponent, health:HealthComponent)->void:
	print("Someone at " + str(movement.position) + " is sound asleep...")
	movement.clear_path()
	health.energy.regen_factor += 0.01
func flee(entity:Entity, movement:MovementComponent, world:ECS_MANAGER)->void:
	print("%d flees!" % entity.uid)
	var flee_from:Vector2 = Vector2(world.WIDTH, world.HEIGHT) * 0.5
	var away_position:Vector2 = movement.position + (movement.position - flee_from) * 50
	
	away_position.x = clampf(away_position.x, 0, world.WIDTH)
	away_position.y = clampf(away_position.y, 0, world.HEIGHT)
	
	var mov_sys:MovementSystem = world.systems[in_registry(MovementSystem)]
	mov_sys.force_move(entity, away_position)
func seek(entity:Entity, world:ECS_MANAGER)->void:
	print("%d hungers..." % entity.uid)
	var center:Vector2 = Vector2(world.WIDTH, world.HEIGHT) * 0.5
	var mov_sys:MovementSystem = world.systems[in_registry(MovementSystem)]
	mov_sys.force_move(entity, center)
