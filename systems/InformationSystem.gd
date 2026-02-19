class_name InformationSystem
extends BaseSystem

var UI_NODE:Control = null
var THEME:Theme = null

func _init(ui_node:Control)->void:
	UI_NODE = ui_node
	THEME = PixelTheme.create()
func instance()->void:
	for uid:int in REG.get_entities_by(INFO_FLAG):
		var info:InformationComponent = REG.COMPONENT_STORE[uid].get(INFO_FLAG)
		if info and not info.panel_ref:
			create_panel(uid)
func process()->void:
	for uid:int in REG.get_entities_by(INFO_FLAG):
		var info:InformationComponent = REG.get_component(uid, INFO_FLAG)
		if info and not info.is_active:
			destroy(info)
			continue
		
		var vis:VisualComponent = REG.get_component(uid, REG.C_FLAGS.VISUAL)
		if vis and vis.queue_destroy:
			destroy(info)
			continue

		if info.is_active and not info.panel_ref:
			create_panel(uid)
		
		if info.is_active and info.panel_ref:
			update(uid, info)
## Generates a UI container for displaying information
func create_panel(uid:int)->void:
	var info:InformationComponent = REG.get_component(uid, INFO_FLAG)
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
	
	var stats:StatsComponent = REG.get_component(uid, STATS_FLAG)
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
		info.containers["STATE"] = mind_state
		vbox.add_child(mind_state)
	info.panel_ref = panel
	UI_NODE.add_child(info.panel_ref)
func update(uid:int, info:InformationComponent)->void:
	var stat:StatsComponent = REG.get_component(uid, STATS_FLAG)
	if stat:
		update_vital_label(info.containers.Blood, stat.blood, "Blood")
		update_vital_label(info.containers.Energy, stat.energy, "Energy")
		update_vital_label(info.containers.Hunger, stat.hunger, "Hunger")
		update_vital_label(info.containers.Thirst, stat.thirst, "Thirst")
	var behavior:BehaviorComponent = REG.get_component(uid, BEHAV_FLAG)
	if behavior:
		info.containers.STATE.text = behavior.active_behavior.behavior_name 
	var mov:MovementComponent = REG.get_component(uid, MOV_FLAG)
	if mov:
		info.panel_ref.position = mov.position + Vector2(-30, -130)
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
