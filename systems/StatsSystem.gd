class_name StatsSystem
extends BaseSystem

func process(REG:REGISTRY)->void:
	for uid:int in REG.get_entities_by(STATS_FLAG):
		var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
		if not stats: continue
		if not stats.is_alive: continue
		
		check_vitals(uid, REG)
		apply_passive_fx(stats)
func apply_passive_fx(stats:StatsComponent)->void:
	stats.energy.modify(stats.energy.regen_factor)
	stats.hunger.modify(stats.hunger.regen_factor)
	stats.thirst.modify(stats.thirst.regen_factor)
	
	if stats.hunger.ratio() > 0.3 and stats.thirst.ratio() > 0.3:
		stats.blood.modify(stats.blood.regen_factor)
	else:
		stats.blood.hurt(0.05)
func check_vitals(uid:int, REG:REGISTRY)->void:
	var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
	if stats.blood.is_depleted():
		stats.is_alive = false
		stats.is_conscious = false
		die(uid, REG)
	if stats.energy.is_depleted() and stats.is_conscious:
		stats.is_conscious = false
		faint(uid, REG)
	if not stats.energy.is_depleted() and not stats.is_conscious:
		if stats.energy.ratio() > 0.2:
			stats.is_conscious = true
func die(uid:int, REG:REGISTRY)->void:
	REG.destroy_entity(uid)
func faint(uid:int, REG:REGISTRY)->void:
	var movement:MovementComponent = REG.get_component(uid, MOV_FLAG)
	if movement and movement.movable:
		movement.movable.clear()
