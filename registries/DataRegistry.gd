## General read-only database (for keeping names, random generation constants, configuration values etc.)
class_name DataRegistry
extends Resource

@export_category("Names")
@export_dir var MALE_NAMES:Array[String] = [
	'Bran',
	'Gorge',
	'Heg',
	'Karkon',
	'Pim'
	]
@export_dir var FEMALE_NAMES:Array[String] = [
	'Acra',
	'Ata',
	'Casa',
	'Elyi',
	'Meyra',
	'Rena'
	]
@export_dir var DUCK_NAMES:Array[String] = [
	'McClucks',
	'Quacks',
	'Sir'
	]

@export_category("Wait time")
@export var EATING_DURATION:float = 2.0
@export var DEATH_DURATION:float = 3.0
@export var DRINK_DURATION:float = 1.5
@export var STUN_DURATION:float = 0.5

@export_category("Item information")
@export_dir var FOOD:Array[String] = [
	'FISH', 'FRUIT', 'MEAT'
	]
@export_dir var RESOURCE:Array[String] = [
	'STONE',
	'WATER',
	'WOOD'
	]
@export_dir var ITEM_TYPE:Array[String] = [
	'EQUIPMENT',
	'FOOD',
	'RESOURCE'
	]
