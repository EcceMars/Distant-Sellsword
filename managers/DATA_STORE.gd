extends Node

const ANIMATIONS:Dictionary = {
	# Actors
	"duck_anim": "res://assets/sprites/actors/duck_anim.tres",
	"f_dwarf": "res://assets/sprites/actors/f_dwarf_anim.tres",
	"f_human": "res://assets/sprites/actors/f_human_anim.tres",
	"f_ranger": "res://assets/sprites/actors/f_ranger_anim.tres",
	"f_woodcutter": "res://assets/sprites/actors/f_woodcutter_anim.tres",
	"m_knight": "res://assets/sprites/actors/m_knight.tres",
	
	# Vegetation
	"pine_tree": "res://assets/sprites/vegetation/pines_anim.tres",
	
	# Structures:
	
	
	}

var _cache:Dictionary = {}

func get_frames(key:String)->Variant:
	if _cache.has(key): return _cache[key]
	if not ANIMATIONS.has(key): push_error("[DATA_STORE] No animation for key: %s" % key)
	
	var resource = load(ANIMATIONS[key])
	_cache[key] = resource
	return resource

func has_animation(key:String)->bool:
	return ANIMATIONS.has(key)
func get_all_anim_names()->Array[String]:
	return ANIMATIONS.keys()
func clear_cache()->void:
	_cache.clear()
