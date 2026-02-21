class_name SPRITESTORE
extends Resource

enum TYPES {
	DEBUG,
	STATIC,
	ANIMATED
	}

@export_custom(PROPERTY_HINT_DICTIONARY_TYPE, "String;String") var CATEGORIES:Dictionary[String, String] = {
	"actors": "res://assets/sprites/actors/",
	"vegetation": "res://assets/sprites/vegetation/",
	"structures": "res://assets/sprites/structures/",
	"items": "res://assets/sprites/items/",
	"effects": "res://assets/sprites/effects/"
	}
