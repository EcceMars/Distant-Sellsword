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
## Creates a generic debug rect to visualize entities
func _default()->void:
	visual = ColorRect.new()
	visual.name = "debug_sprite"
	visual.color = Color.PURPLE
	visual.size = Vector2.ONE * 8
	visual.position = visual.size * -0.5
