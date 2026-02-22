class_name TERRAINSTORE
extends Resource

enum BIOME {
	WATER,
	# SAND,
	GRASS,
	# FOREST,
	# DIRT
	}
@export var BIOME_COLORS:Dictionary = {
	BIOME.WATER: Color(0.18, 0.42, 0.72),
	# BIOME.SAND: Color(0.85, 0.78, 0.52),
	BIOME.GRASS: Color(0.44, 0.70, 0.30),
	# BIOME.FOREST: Color(0.20, 0.45, 0.18),
	# BIOME.DIRT: Color(0.55, 0.38, 0.22)
	}
@export_custom(PROPERTY_HINT_ARRAY_TYPE, "Array") var BIOME_THRESHOLDS:Array[Array] = [
	[-0.3, BIOME.WATER],
	# [-0.1, BIOME.SAND],
	[0.4, BIOME.GRASS],
	# [0.7, BIOME.FOREST],
	# [1.0, BIOME.DIRT]
	]
# Optional helper: Sample BIOME from noise value (can be called from registries)
func sample_biome(value:float)->BIOME:
	for threshold: Array in BIOME_THRESHOLDS:
		if value <= threshold[0]:
			return threshold[1]
	return BIOME.GRASS
