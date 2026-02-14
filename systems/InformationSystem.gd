class_name InformationSystem
extends BaseSystem

var UI_NODE:Control = null
var THEME:Theme = null

func _init(ui_node:Control)->void:
	UI_NODE = ui_node
	THEME = PixelTheme.create()
func instance(REG:REGISTRY)->void:
	for uid:int in REG.get_entities_by(INFO_FLAG):
		var info:InformationComponent = REG.COMPONENT_STORE[uid].get(INFO_FLAG)
		if info and not info.panel_ref:
			create_panel(uid, REG)
func process(REG:REGISTRY)->void:
	for uid:int in REG.get_entities_by(INFO_FLAG):
		var info:InformationComponent = REG.COMPONENT_STORE[uid].get(INFO_FLAG)
		if not info.is_active: continue
		
		if info.is_active and not info.panel_ref:
			create_panel(uid, REG)
		
		if info.is_active and info.panel_ref:
			update(uid, REG)
## Generates a UI container for displaying information
func create_panel(uid:int, REG:REGISTRY)->void:
	var info:InformationComponent = REG.COMPONENT_STORE[uid].get(INFO_FLAG)
	var panel:PanelContainer = PanelContainer.new()
	panel.name = "InfoPanel_%d" % uid
	panel.theme = THEME
	
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
	
	var stats:StatsComponent = REG.COMPONENT_STORE[uid].get(STATS_FLAG)
	if stats:
		for vital_data in [
			["Blood", stats.blood],
			["Energy", stats.energy],
			["Hunger", stats.hunger],
			["Thirst", stats.thirst]
		]:
			var label:Label = Label.new()
			label.name = vital_data[0]
			label.add_theme_font_size_override("font_size", 12)  # Smaller stats
			info.id.set(vital_data[0].to_lower(), vital_data[1])
			info.containers[vital_data[0]] = label
			vbox.add_child(label)
		
	var behavior:BehaviorComponent = REG.get_component(uid, BEHAV_FLAG)
	if behavior:
		var mind_state:Label = Label.new()
		mind_state.name = "Behavior"
		mind_state.add_theme_font_size_override("font_size", 11)
		info.id.mental_state = behavior.active_behavior
		info.containers["STATE"] = mind_state
		vbox.add_child(mind_state)
		
	info.panel_ref = panel
	UI_NODE.add_child(panel)
#TASK: Maybe there would be no need to check for components here as the [InformationComponent.ID] members tend to accuse that the entity does have such components (checking is nonetheless safer)
func update(uid:int, REG:REGISTRY)->void:
	var info:InformationComponent = REG.COMPONENT_STORE[uid][INFO_FLAG]
	if not info: return
	if not info.is_active: return
	if not is_instance_valid(info.panel_ref): return
	
	var movement:MovementComponent = REG.COMPONENT_STORE[uid].get(MOV_FLAG)
	if movement:
		# Panel above entity
		var panel_size:Vector2 = info.panel_ref.size
		var ent_center:Vector2 = movement.position - (Vector2.DOWN * 8)
		var panel_pos:Vector2 = Vector2(
			ent_center.x - (panel_size.x * 0.5),
			ent_center.y - panel_size.y - 2
			)
		info.panel_ref.position = panel_pos.floor()
	
	var stat:StatsComponent = REG.COMPONENT_STORE[uid].get(STATS_FLAG)
	if stat:
		update_vital_label(info.containers.Blood, stat.blood, "Blood")
		update_vital_label(info.containers.Energy, stat.energy, "Energy")
		update_vital_label(info.containers.Hunger, stat.hunger, "Hunger")
		update_vital_label(info.containers.Thirst, stat.thirst, "Thirst")
	var behavior:BehaviorComponent = REG.get_component(uid, BEHAV_FLAG)
	if behavior:
		info.containers.STATE.text = behavior.active_behavior.name 
func update_vital_label(label:Label, vital:StatsComponent.Vital, name:String)->void:
	var ratio:float = vital.ratio()
	label.text = "%s: %.0f" % [name, vital.value]
	
	# Color coding based on vital ratio
	if ratio > 0.7:
		label.add_theme_color_override("font_color", Color.GREEN)
	elif ratio > 0.3:
		label.add_theme_color_override("font_color", Color.YELLOW)
	else:
		label.add_theme_color_override("font_color", Color.ORANGE_RED)
## Destroys a panel
func destroy(info:InformationComponent)->void:
	if is_instance_valid(info.panel_ref):
		info.panel_ref.queue_free()
	info.panel_ref = null
