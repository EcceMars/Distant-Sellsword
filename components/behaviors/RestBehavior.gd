## Rest behavior - entity stops to regenerate energy. Will enter a unconscious state if energy depletes completely.
@tool
class_name RestBehavior
extends Behavior

## Energy ratio threshold below which resting becomes urgent (0.0 to 1.0)
@export_range(0.0, 1.0, 0.05) var energy_threshold:float = 0.2

## Base priority when at threshold
@export_range(0.0, 2.0, 0.1) var base_priority:float = 0.8

## Energy regeneration boost while resting
@export var regen_boost:float = 0.01

func _init() -> void:
	behavior_name = "Rest"
	description = "Stops moving to regenerate energy"
	enabled = true

func priority(uid:int, REG:REGISTRY) -> float:
	if not enabled:return 0.0
	
	var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
	if not stats:return 0.0
	
	# Maximum priority if unconscious (fainting)
	if not stats.is_conscious:return 1.0
	
	var energy_ratio:float = stats.energy.ratio()
	
	# Priority increases as energy drops below threshold
	if energy_ratio < energy_threshold:
		return base_priority - (energy_ratio / energy_threshold) * 0.3
	
	return 0.0

func act(uid:int, REG:REGISTRY)->void:
	var movement:MovementComponent = REG.get_component(uid, MOV_FLAG)
	var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
	
	# Stop moving
	if movement and movement.movable:
		movement.movable.clear()
	
	# Boost energy regeneration while resting
	if stats:
		stats.energy.regen_factor += regen_boost

func on_exit(uid:int, REG:REGISTRY) -> void:
	# Remove regen boost when no longer resting
	var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
	if stats:
		stats.energy.regen_factor -= regen_boost
