## Generates and displays a biome texture on REG.TERRAIN.
## Each pixel represents one tile at REG.SCALE resolution.
class_name TerrainRegistry
extends BaseRegistry

const BIOME = REG.DATA.TERRAIN.BIOME
var BIOME_THRESHOLDS = REG.DATA.TERRAIN.BIOME_THRESHOLDS
var BIOME_COLORS = REG.DATA.TERRAIN.BIOME_COLORS

## Flat biome lookup, keyed by grid position.
var _biome_map:Dictionary[Vector2i, BIOME] = {}
## Per-biome position cache for fast nearest queries.
var _biome_positions:Dictionary[BIOME, Array] = {}

var _noise:FastNoiseLite = null

func _init(_seed:int = 0)->void:
	_noise = FastNoiseLite.new()
	_noise.seed = _seed
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = 0.03
	_generate()

## Samples noise, fills [member _biome_map], builds and displays the texture.
func _generate()->void:
	## Initialise cache buckets
	for biome:BIOME in BIOME.values():
		_biome_positions[biome] = []

	var img:Image = Image.create(REG.WIDTH, REG.HEIGHT, false, Image.FORMAT_RGB8)
	
	for y:int in REG.HEIGHT:
		for x:int in REG.WIDTH:
			var value:float = _noise.get_noise_2d(float(x), float(y))
			var biome:BIOME = REG.DATA.TERRAIN.sample_biome(value)
			var in_grid:Vector2i = Vector2i(x, y)
			_biome_map[in_grid] = biome
			_biome_positions[biome].append(in_grid)
			img.set_pixel(x, y, BIOME_COLORS[biome])
	
	var texture:ImageTexture = ImageTexture.create_from_image(img)
	var sprite:Sprite2D = Sprite2D.new()
	sprite.name = "TerrainTexture"
	sprite.texture = texture
	sprite.centered = false
	## Scale sprite pixels up to match REG.SCALE tile size.
	sprite.scale = Vector2(REG.SCALE, REG.SCALE)
	
	REG.TERRAIN.add_child(sprite)
## Maps a noise [param value] to a [enum Biome] via [constant BIOME_THRESHOLDS].
#func _sample_biome(value:float)->BIOME:
	#for threshold:Array in BIOME_THRESHOLDS:
		#if value <= threshold[0]:
			#return threshold[1]
	#return BIOME.GRASS

## Returns the [enum Biome] at [param world_pos].
func get_biome(world_pos:Vector2)->BIOME:
	var grid:Vector2i = Vector2i(world_pos / REG.SCALE)
	return _biome_map.get(grid, BIOME.GRASS)

## Returns true if [param world_pos] is a water tile.
func is_water(world_pos:Vector2)->bool:
	return get_biome(world_pos) == BIOME.WATER
## Returns true if any of the 8 neighbours of [param world_pos] is a water tile.
func is_water_adjacent(world_pos:Vector2)->bool:
	var grid:Vector2i = Vector2i(world_pos / REG.SCALE)
	for dx:int in [-1, 0, 1]:
		for dy:int in [-1, 0, 1]:
			if dx == 0 and dy == 0: continue
			if _biome_map.get(grid + Vector2i(dx, dy)) == BIOME.WATER:
				return true
	return false
## Returns the nearest world position of [param biome] to [param world_pos].
## Returns -Vector2.ONE (out of bounds) if none exists.
func nearest_of_biome(world_pos:Vector2, biome:BIOME)->Vector2:
	var positions:Array = _biome_positions.get(biome, [])
	if positions.is_empty(): return -Vector2.ONE

	var best_dist:float = INF
	var best_pos:Vector2 = -Vector2.ONE

	for grid:Vector2i in positions:
		var candidate:Vector2 = Vector2(grid * REG.SCALE)
		var dist:float = world_pos.distance_to(candidate)
		if dist < best_dist:
			best_dist = dist
			best_pos = candidate

	return best_pos

## Convenience wrapper kept for existing callers.
func nearest_water(world_pos:Vector2)->Vector2:
	return nearest_of_biome(world_pos, BIOME.WATER)

## GROUND entities cannot spawn on water. AMPHIBIAN and WATER types can.
## AIR and PHASE types are unrestricted.
func can_spawn(world_pos:Vector2, mov_type:MovementComponent.Movable.Flag)->bool:
	var biome:BIOME = get_biome(world_pos)
	match mov_type:
		MovementComponent.Movable.Flag.GROUND:
			return biome != BIOME.WATER
		MovementComponent.Movable.Flag.WATER:
			return biome == BIOME.WATER
		MovementComponent.Movable.Flag.AMPHIBIAN:
			return true
		MovementComponent.Movable.Flag.AIR, MovementComponent.Movable.Flag.PHASE:
			return true
	return true
## Returns a random world position valid for [param mov_type], or -Vector2.ONE on failure.
func random_position_for(mov_type:MovementComponent.Movable.Flag)->Vector2:
	var attempts:int = 32
	while attempts > 0:
		var x:int = randi_range(0, REG.WIDTH - 1)
		var y:int = randi_range(0, REG.HEIGHT - 1)
		var candidate:Vector2 = Vector2(x, y) * REG.SCALE
		if can_spawn(candidate, mov_type):
			return candidate
		attempts -= 1
	push_warning("[TerrainRegistry] No valid spawn found for mov_type: %d" % mov_type)
	return -Vector2.ONE
