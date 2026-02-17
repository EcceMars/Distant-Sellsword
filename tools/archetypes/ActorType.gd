class_name ActorType
extends EntityArchetype

func _init() -> void:
	archetype = "Player"
	
	# Visual
	sprite_type = VisualComponent.SpriteType.ANIMATED
	anim_key = "m_knight"
	
	# Movement
	moves = true
	is_solid = true
	movement_type = MovementComponent.Movable.Flag.GROUND
	movement_speed = 5.0
	
	# Stats
	has_stats = true
	blood_max = 100.0
	blood_regen = 0.1
	energy_max = 100.0
	energy_regen = 0.5
	hunger_max = 100.0
	hunger_regen = -0.2
	thirst_max = 100.0
	thirst_regen = -0.3
	
	# No AI behavior for player
	has_behavior = false
	
	# Animation
	has_animations = true
	# Uses default animation mappings
	
	# Information
	has_information = true
	char_name = "Iphrit"
	gender = "Male"
	show_ui = true
	
	# Player control
	is_actor = true
