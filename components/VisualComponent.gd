class_name VisualComponent
extends BaseComponent

var visual:Node = null
var is_static:bool = true

func _init(anchor_node:Node, visual_node:Node = null, _is_static:bool = is_static)->void:
	if not visual_node or not visual_node in [ColorRect, Sprite2D, AnimatedSprite2D]:
		_default()
	else:
		visual = visual_node
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
	var ori_color:Color = visual.color
	visual.create_tween() \
		.tween_property(visual, "color", Color.WHITE, 0.1)
	visual.color = ori_color
	visual.create_tween() \
		.tween_property(visual, "self_modulate", Color.BLACK, 3.0) \
		.finished.connect(func(): visual.queue_free())
