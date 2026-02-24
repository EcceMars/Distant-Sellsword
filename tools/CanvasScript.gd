class_name CanvasScript
extends Node2D

var DEBUG:bool = true
## Works with a two point array, where point a is the start and b the end
var debug_lines:Dictionary[int, Array] = {}

var GRID_WIDTH:int = REG.WIDTH * REG.SCALE +1
var GRID_HEIGHT:int = REG.HEIGHT * REG.SCALE +1
var GRID_OFFSET:Vector2 = Vector2.ONE * REG.SCALE * 0.5
var TILE_RECT:Rect2 = Rect2(0, 0, REG.SCALE, REG.SCALE)

var mov_sys:MovementSystem = null

func update_canvas()->void:
	GRID_WIDTH= REG.WIDTH * REG.SCALE +1
	GRID_HEIGHT = REG.HEIGHT * REG.SCALE +1
	TILE_RECT= Rect2(0, 0, REG.SCALE, REG.SCALE)

func _draw()->void:
	if not DEBUG: return
	_draw_grid()
	#for mov_component:MovementComponent in REG.get_all_components_of(REG.C_FLAGS.MOVE):
		#draw_string(ThemeDB.fallback_font, mov_component.position, str(mov_component.position))
	if not mov_sys: mov_sys = REG.SYSTEMS["MovementSystem"]
	for point:Vector2i in mov_sys.blocked_positions:
		var rect:Rect2 = Rect2(point, TILE_RECT.end)
		draw_rect(rect, Color.SKY_BLUE, true)
	_draw_mov_target()
func _draw_grid()->void:
	for col:int in range(0, GRID_WIDTH, REG.SCALE):
		draw_string(ThemeDB.fallback_font, Vector2i(col, -10), str(col))
		draw_line(Vector2i(col, 0), Vector2i(col, GRID_HEIGHT), Color.DARK_RED)
	for row:int in range(0, GRID_HEIGHT, REG.SCALE):
		draw_string(ThemeDB.fallback_font, Vector2i(-10, row), str(row))
		draw_line(Vector2i(0, row), Vector2i(GRID_WIDTH, row), Color.DARK_RED)
func _draw_mov_target()->void:
	for uid:int in debug_lines:
		var request:Array = debug_lines[uid].duplicate()
		if not request or request.size() < 1: continue
		draw_line(debug_lines[uid][0] + GRID_OFFSET, debug_lines[uid][1] + GRID_OFFSET, Color.RED, 2)
