class_name CanvasScript
extends Node2D

var DEBUG:bool = false

var GRID_WIDTH:int = REG.WIDTH * REG.SCALE +1
var GRID_HEIGHT:int = REG.HEIGHT * REG.SCALE +1
var TILE_RECT:Rect2 = Rect2(0, 0, REG.SCALE, REG.SCALE)

var queue_deletion:Array[Node] = []

var mov_sys:MovementSystem = null

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
func _draw()->void:
	if not DEBUG: return
	_draw_grid()
	#for mov_component:MovementComponent in REG.get_all_components_of(REG.C_FLAGS.MOVE):
		#draw_string(ThemeDB.fallback_font, mov_component.position, str(mov_component.position))
	if not mov_sys: mov_sys = REG.SYSTEMS["MovementSystem"]
	for point:Vector2i in mov_sys.blocked_positions:
		var rect:Rect2 = Rect2(point, TILE_RECT.end)
		draw_rect(rect, Color.SKY_BLUE, true)
func _draw_grid()->void:
	for col:int in range(0, GRID_WIDTH, REG.SCALE):
		draw_string(ThemeDB.fallback_font, Vector2i(col, -10), str(col))
		draw_line(Vector2i(col, 0), Vector2i(col, GRID_HEIGHT), Color.DARK_RED)
	for row:int in range(0, GRID_HEIGHT, REG.SCALE):
		draw_string(ThemeDB.fallback_font, Vector2i(-10, row), str(row))
		draw_line(Vector2i(0, row), Vector2i(GRID_WIDTH, row), Color.DARK_RED)
