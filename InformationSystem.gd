class_name InformationSystem
extends System

var UI_NODE:Control = null
func _init(ui_node:Control)->void:
	UI_NODE = ui_node
func instance(world:ECS_MANAGER)->void:
	for entity:Entity in world.get_all_with_component(InformationComponent):
		var info:InformationComponent = entity.get_component(InformationComponent)
		if info and not info.panel_ref:
			create_panel(entity, info)
func process(world:ECS_MANAGER)->void:
	for entity:Entity in world.get_all_with_component(InformationComponent):
		var info:InformationComponent = entity.get_component(InformationComponent)
		if not info: continue
		
		if info.is_active and not info.panel_ref:
			create_panel(entity, info)
		
		if info.is_active and info.panel_ref:
			update(entity, info)
## Generates a UI container for displaying information
func create_panel(entity:Entity, info:InformationComponent)->void:
	var panel:PanelContainer = PanelContainer.new()
	print(info.id.name)
	panel.name = "InfoPanel_%d" % entity.uid
	
	var vbox:VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	info.containers["VBOX"] = vbox
	panel.add_child(vbox)
	
	var title:Label = Label.new()
	title.name = "Name"
	title.text = info.id.name
	title.add_theme_font_size_override("font_size", 12)
	info.containers["Title"] = title
	vbox.add_child(title)
	
	var health:HealthComponent = entity.get_component(HealthComponent)
	if health:
		var blood:Label = Label.new()
		blood.name = "Blood"
		info.id.blood = health.blood
		info.containers["Blood"] = blood
		vbox.add_child(blood)
		
		var energy:Label = Label.new()
		energy.name = "Energy"
		info.id.energy = health.energy
		info.containers["Energy"] = energy
		vbox.add_child(energy)
		
		var hunger:Label = Label.new()
		hunger.name = "Hunger"
		info.id.hunger = health.hunger
		info.containers["Hunger"] = hunger
		vbox.add_child(hunger)
		
		var thirst:Label = Label.new()
		thirst.name = "Thirst"
		info.id.thirst = health.thirst
		info.containers["Thirst"] = thirst
		vbox.add_child(thirst)
		
	var behavior:BehaviorComponent = entity.get_component(BehaviorComponent)
	if behavior:
		var mind_state:Label = Label.new()
		mind_state.name = "Behavior"
		info.id.mental_state = behavior.active_behavior
		info.containers["STATE"] = mind_state
		vbox.add_child(mind_state)
		
	info.panel_ref = panel
	UI_NODE.add_child(panel)
#TASK: Maybe there would be no need to check for components here as the [InformationComponent.ID] members tend to accuse that the entity does have such components (checking is nonetheless safer)
func update(entity:Entity, info:InformationComponent)->void:
	if not info.is_active: return
	if not is_instance_valid(info.panel_ref): return
	
	var movement:MovementComponent = entity.get_component(MovementComponent)
	if movement:
		# Panel above entity
		info.panel_ref.position = movement.position + Vector2(-30, -50)
	
	var health:HealthComponent = entity.get_component(HealthComponent)
	if health:
		info.containers.Blood.text = "Blood: %.1f/%.0f" % [health.blood.value, health.blood.maximum]
		info.containers.Energy.text = "Energy: %.1f/%.0f" % [health.energy.value, health.energy.maximum]
		info.containers.Hunger.text = "Hunger: %.1f/%.0f" % [health.hunger.value, health.hunger.maximum]
		info.containers.Thirst.text = "Thirst: %.1f/%.0f" % [health.thirst.value, health.thirst.maximum]
	var behavior:BehaviorComponent = entity.get_component(BehaviorComponent)
	if behavior:
		info.containers.STATE.text = behavior.active_behavior.name 
## Destroys a panel
func destroy(info:InformationComponent)->void:
	if is_instance_valid(info.panel_ref):
		info.panel_ref.queue_free()
	info.panel_ref = null
