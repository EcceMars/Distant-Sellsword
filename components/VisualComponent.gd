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
	var tween:Tween = visual.create_tween()
	# Quick flash to dark (very brief)
	tween.tween_property(visual, "modulate", Color(0.06, 0.06, 0.06), 0.08)
	# Immediately chain: go back toward original for ~0.1–0.15 s total "hit" feel
	tween.tween_property(visual, "modulate", Color.WHITE, 0.12)
	# Then long death fade
	tween.tween_property(visual, "modulate", Color.BLACK, 2.8)
	tween.tween_callback(visual.queue_free)
func _to_string()->String:
	return str("VisualComponent:\n\tStatic ", is_static, " of type ", "ERROR" if not visual else visual.get_script())
