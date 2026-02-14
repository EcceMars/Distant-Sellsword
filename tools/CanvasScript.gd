extends Node2D

var visual_nodes:Array[Node] = []
var queue_deletion:Array[Node] = []

## Use [Main.gd]'s visual_nodes array here
func set_ref(v_arr:Array[Node])->void:
	visual_nodes = v_arr
## Request a visual node to be deleted after a death animation
func request_removal(visual:Node)->void:
	if not is_instance_valid(visual): return
	if visual in queue_deletion: return

	queue_deletion.append(visual)
	
	var tween:Tween = visual.create_tween()
	# Quick flash to dark (very brief)
	tween.tween_property(visual, "modulate", Color(0.06, 0.06, 0.06), 0.08)
	tween.tween_property(visual, "modulate", Color(15, 15, 15), 0.02)
	tween.tween_property(visual, "modulate", Color(1, 1, 1), 0.5)
	tween.tween_property(visual, "modulate", Color.BLACK, 2.8)
	tween.tween_property(visual, "modulate", Color(0, 0, 0, 0), 3.0)
	tween.tween_callback(func(): cleanup(visual))
func cleanup(visual:Node)->void:
	visual_nodes.erase(visual)
	queue_deletion.erase(visual)
	visual.queue_free()
