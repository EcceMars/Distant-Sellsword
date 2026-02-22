@icon("res://assets/img/icons/store_base.png")
class_name DATASTORE
extends Resource

@export var ACTIONS:	ACTIONSTORE		: get = _get_actions
@export var ARCHETYPES:	ENTITYSTORE		: get = _get_archetypes
@export var ITEMS:		ITEMSTORE		: get = _get_items
@export var LORE:		LORESTORE		: get = _get_lore
@export var SPRITES:	SPRITESTORE		: get = _get_sprites
@export var TERRAIN:	TERRAINSTORE	: get = _get_terrain

# Private backing fields (never exported, never set from outside)
var _actions:		ACTIONSTORE
var _archetypes:	ENTITYSTORE
var _items:			ITEMSTORE
var _lore:			LORESTORE
var _sprites:		SPRITESTORE
var _terrain:		TERRAINSTORE

func _init()->void:
	_ensure_all_loaded()

func _ensure_all_loaded() -> void:
	_actions	= _actions		if _actions		else ACTIONSTORE.new()
	_archetypes	= _archetypes	if _archetypes	else ENTITYSTORE.new()
	_items		= _items		if _items		else ITEMSTORE.new()
	_lore		= _lore			if _lore		else LORESTORE.new()
	_sprites	= _sprites		if _sprites		else SPRITESTORE.new()
	_terrain	= _terrain		if _terrain		else TERRAINSTORE.new()

# Getters — make them one-liners if you want
func _get_actions()		-> ACTIONSTORE:		return _actions
func _get_archetypes()	-> ENTITYSTORE:		return _archetypes
func _get_items()		-> ITEMSTORE:		return _items
func _get_lore()		-> LORESTORE:		return _lore
func _get_sprites()		-> SPRITESTORE:		return _sprites
func _get_terrain()		-> TERRAINSTORE:	return _terrain
