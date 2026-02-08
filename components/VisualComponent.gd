class_name VisualComponent
extends BaseComponent

var visual:Node = null
var is_static:bool = true

func _init(anchor_node:Node, visual_node:Node = null, _is_static:bool = is_static)->void:
	# If visual_node is null or is not of an accepted type
	if not visual_node or not (visual_node is ColorRect or visual_node is AnimatedSprite2D):
		_default()		# Generates a default ColorRect to debug
	else:
		visual = visual_node.duplicate()	# visual_node is of any of the three types
		if visual is AnimatedSprite2D:
			visual.name = visual.sprite_frames.resource_path
			visual.animation = "idle"
		else:
			push_warning("Here is a problem ", visual)
	is_static = _is_static
	anchor_node.add_child(visual)
	anchor_node.visual_nodes.append(visual)
## Creates a generic debug rect to visualize entities
func _default()->void:
	visual = ColorRect.new()
	visual.name = "debug_sprite"
	visual.color = Color.PURPLE
	visual.size = Vector2.ONE * 8
	visual.position = visual.size * -0.5
func clear()->void:
	if visual is ColorRect:
		var ori_color:Color = visual.color
		visual.create_tween() \
			.tween_property(visual, "color", Color.WHITE, 0.1)
		visual.color = ori_color
		visual.create_tween() \
			.tween_property(visual, "self_modulate", Color.BLACK, 3.0) \
			.finished.connect(func(): visual.queue_free())
	else:
		var ori_color:Color = visual.self_modulate
		visual.create_tween() \
			.tween_property(visual, "self_modulate", Color.WHITE, 0.1)
		visual.self_modulate = ori_color
		visual.create_tween() \
			.tween_property(visual, "self_modulate", Color.BLACK, 3.0) \
			.finished.connect(func(): visual.queue_free())
func _to_string()->String:
	return str("VisualComponent:\n\tStatic ", is_static, " of type ", "ERROR" if not visual else visual.get_script())
