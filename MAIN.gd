extends Node

const POPULATION:int = 200
const FRAME_LEN:float = 0.04
const WIDTH:int = 600
const HEIGHT:int = 400

var WORLD:ECS_MANAGER
var RUNNING:bool = false
var frame:float = FRAME_LEN
var dead_count:int = 0

var canvas_node:Node2D = null
var ui_node:Control = null
var visual_nodes:Array[Node] = []

var anim_texture_list:Dictionary[String, Variant] = {
	"PLAYER": "res://assets/sprites/actors/m_knight.tres",
	"RITA": "res://assets/sprites/actors/f_human_anim.tres",
	"WANDERER": {
		"DUCK": "res://assets/sprites/actors/duck_anim.tres",
		"DWARF": "res://assets/sprites/actors/f_dwarf_anim.tres",
		"RANGER": "res://assets/sprites/actors/f_ranger_anim.tres",
		"WOODCUTTER": "res://assets/sprites/actors/f_woodcutter_anim.tres"
	},
	"TREE": "res://assets/sprites/vegetation/pines_anim.tres"
}
var sprites_ref:Dictionary = {}
func _ready()->void:
	_load_sprites()
	generate()
func _load_sprites()->void:
	for type in anim_texture_list:
		if anim_texture_list[type] is Dictionary:
			for w_type in anim_texture_list[type]:
				var anim_sprite:AnimatedSprite2D = AnimatedSprite2D.new()
				var res_path:String = anim_texture_list[type].get(w_type)
				anim_sprite.sprite_frames = load(res_path)
				anim_sprite.y_sort_enabled = true
				anim_sprite.play("idle")
				sprites_ref[w_type] = anim_sprite
		else:
			var anim_sprite:AnimatedSprite2D = AnimatedSprite2D.new()
			var frames = load(anim_texture_list[type])
			anim_sprite.sprite_frames = frames
			anim_sprite.y_sort_enabled = true
			anim_sprite.play("idle")
			sprites_ref[type] = anim_sprite
func _process(_delta:float)->void:
	if not RUNNING: return
	if frame >= FRAME_LEN:
		for system:System in WORLD.systems.values().duplicate():
			system.process(WORLD)
		frame = 0.0
	frame += _delta
	if WORLD.dying_world:
		RUNNING = false
		generate()
func generate()->void:
	if WORLD:
		await get_tree().create_timer(3).timeout
		var visible:Array = WORLD.get_all_with_component(VisualComponent)
		for visual in visible:
			var vcomp:VisualComponent = visual.get_component(VisualComponent)
			if vcomp:
				vcomp.clear()
		await get_tree().create_timer(3.5).timeout
		print("\n\n\n---------World is anew!---------\n\n\n")
		canvas_node.queue_free()
		ui_node.queue_free()
	WORLD = null
	WORLD = ECS_MANAGER.new(POPULATION, WIDTH, HEIGHT)
	prepeare_canvas()
	prepare_ui()
	for pop in WORLD.POPULATION:
		var pos:Vector2 = Vector2(randi() % WIDTH, randi() % HEIGHT)
		WORLD.spawn_entity(
			[
				MovementComponent.new(pos),
				VisualComponent.new(canvas_node, sprites_ref.TREE)
			]
		)
	var hero:Entity = WORLD.entities.pick_random()
	var h_pos:Vector2 = hero.get_component(MovementComponent).position
	WORLD.extend_ent_component(hero, MovementComponent.new(h_pos, true, 1), true)
	WORLD.extend_ent_component(hero, ControllerComponent.new(canvas_node, hero))
	WORLD.extend_ent_component(hero, HealthComponent.new(), true)
	WORLD.extend_ent_component(hero, InformationComponent.new("Hero", "Male", true))
	WORLD.extend_ent_component(hero, VisualComponent.new(canvas_node, sprites_ref.PLAYER, false), true)
	var health:HealthComponent = hero.get_component(HealthComponent)
	health.energy.regen_factor = 0.5
	
	for n in POPULATION * 0.4:
		var elected:Entity = WORLD.entities.pick_random()
		while elected == hero: elected = WORLD.entities.pick_random()
		
		var old_pos:Vector2 = elected.get_component(MovementComponent).position
		WORLD.extend_ent_component(elected, HealthComponent.new(), true)
		WORLD.extend_ent_component(elected, MovementComponent.new(old_pos, true), true)
		WORLD.extend_ent_component(elected, BehaviorComponent.new())
		var rand_name:String = ["DUCK", "DWARF", "RANGER", "WOODCUTTER"].pick_random()
		WORLD.extend_ent_component(elected, VisualComponent.new(canvas_node, sprites_ref[rand_name], false), true)
	var rita:Entity = WORLD.entities.pick_random()
	while rita == hero or not rita.get_component(MovementComponent).movable: rita = WORLD.entities.pick_random()
	var rita_pos:Vector2 = rita.get_component(MovementComponent).position
	WORLD.extend_ent_component(rita, MovementComponent.new(rita_pos, true, 0.7), true)
	WORLD.extend_ent_component(rita, VisualComponent.new(canvas_node, sprites_ref.RITA, false), true)
	WORLD.extend_ent_component(rita, InformationComponent.new("Rita", "Female", true))
	
	# Start systems
	WORLD.start_system(MovementSystem.new())
	var visual_system:VisualSystem = VisualSystem.new()
	visual_system.instance(WORLD)
	WORLD.start_system(visual_system)
	var controller:ControllerSystem = ControllerSystem.new(WORLD, hero.get_component(ControllerComponent))
	WORLD.start_system(controller)
	WORLD.start_system(HealthSystem.new())
	WORLD.start_system(BehaviorSystem.new())
	var info_system:InformationSystem = InformationSystem.new(ui_node)
	info_system.instance(WORLD)
	WORLD.start_system(info_system)
	
	RUNNING = true
## For now, the canvas node only serves to y_sort the sprites
func prepeare_canvas()->void:
	canvas_node = Node2D.new()
	canvas_node.name = "SPRITE_CANVAS"
	canvas_node.y_sort_enabled = true
	var canvas_script:GDScript = load("res://CanvasScript.gd")
	canvas_node.set_script(canvas_script)
	canvas_node.set_ref(visual_nodes)
	canvas_node.process_mode = Node.PROCESS_MODE_INHERIT
	add_child(canvas_node)
## Prepares the UI container for [InformationComponent]
func prepare_ui()->void:
	ui_node = Control.new()
	ui_node.name = "UI_CONTAINER"
	ui_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ui_node)
