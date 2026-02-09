class_name VisualComponent
extends BaseComponent

var visual:Node = null
var canvas:Node2D = null
var is_static:bool = true
var queue_deletion:bool = false

## [param _canvas_node] expects _canvas_node to hold the script [CanvasScript.gd]
func _init(_canvas_node:Node2D, visual_node:Node = null, _is_static:bool = is_static)->void:
	# If visual_node is null or is not of an accepted type
	if not visual_node or not (visual_node is ColorRect or visual_node is AnimatedSprite2D):
		_default()		# Generates a default ColorRect to debug
	else:
		visual = visual_node.duplicate()
		visual.name = visual.sprite_frames.resource_path
		visual.animation = "idle"
	is_static = _is_static
	canvas = _canvas_node
	canvas.add_child(visual)
	canvas.visual_nodes.append(visual)
## Creates a generic debug rect to visualize entities
func _default()->void:
	visual = ColorRect.new()
	visual.name = "debug_sprite"
	visual.color = Color.PURPLE
	visual.size = Vector2.ONE * 8
	visual.position = visual.size * -0.5
## Debug death animation
func clear()->void:
	if queue_deletion or not is_instance_valid(visual): return
	queue_deletion = true
	
	# Delegates the death animation and cleanup to the canvas_node
	if canvas and canvas.has_method("request_removal"):
		canvas.request_removal(visual)
func _to_string()->String:
	return str("VisualComponent:\n\tStatic ", is_static, " of type ", "ERROR" if not visual else visual.get_script())
