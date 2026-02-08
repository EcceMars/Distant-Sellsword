class_name HealthSystem
extends System

func process(world:ECS_MANAGER)->void:
	for entity:Entity in world.get_all_with_component(HealthComponent):
		var health:HealthComponent = entity.get_component(HealthComponent)
		if not health:
			continue
		if not health.is_alive:
			continue
		check_vitals(entity, world)
		apply_passive_fx(health)
func apply_passive_fx(health:HealthComponent)->void:
	health.energy.modify(health.energy.regen_factor)
	
	health.hunger.modify(health.hunger.regen_factor)
	health.thirst.modify(health.thirst.regen_factor)
	
	if health.hunger.ratio() > 0.3 and health.thirst.ratio() > 0.3:
		health.blood.modify(health.blood.regen_factor)
	else:
		health.blood.hurt(0.05)
func check_vitals(entity:Entity, world:ECS_MANAGER)->void:
	var health:HealthComponent = entity.get_component(HealthComponent)
	if not health: return
	if health.blood.is_depleted():
		health.is_alive = false
		health.is_conscious = false
		die(entity, world)
		return
	if health.energy.is_depleted() and health.is_conscious:
		health.is_conscious = false
		if randf() < 0.3:
			faint(entity)
		else:
			die(entity, world)
			return
	if not health.energy.is_depleted() and not health.is_conscious:
		if health.energy.ratio() > 0.2:
			health.is_conscious = true
			wake_up(entity)
func die(entity:Entity, world:ECS_MANAGER)->void:
	print("%d has died!" % entity.uid)
	world.despawn_entity(entity)
func faint(entity:Entity)->void:
	print("%d has fainted!" % entity.uid)
	var movement:MovementComponent = entity.get_component(MovementComponent)
	if movement and movement.movable:
		movement.movable.target.clear()
		movement.movable.target.append(movement.position)
		movement.movable.has_target = false
func wake_up(entity:Entity)->void:
	print("%d has regained consciouness!" % entity.uid)
