## All configuration data for a single archetype.
## Members are read by [method _build] to assemble components.
class_name EntityData
extends Resource

func _init()->void: pass
@export_group("Visuals")
@export var sprite_type:VisualComponent.TYPES = VisualComponent.TYPES.DEBUG
@export var sprite_key:SpriteFrames = null
@export var has_animations:bool = false
@export var debug_color:Color = Color.PURPLE

@export_group("Movement")
@export var moves:bool = false
@export var is_solid:bool = false
@export var is_pushable:bool = false
@export var move_type:MovementComponent.Movable.Flag = MovementComponent.Movable.Flag.GROUND
@export var move_speed:float = 1.0

@export_group("Stats")
@export var has_information:bool = false
@export var char_name:String = ""
@export var gender:String = "Female"
@export var has_stats:bool = false
@export var blood_max:float = 100.0
@export var blood_regen:float = 0.1
@export var energy_max:float = 100.0
@export var energy_regen:float = 0.5
@export var hunger_max:float = 100.0
@export var hunger_regen:float = -0.01
@export var thirst_max:float = 100.0
@export var thirst_regen:float = -0.02

@export_group("Behaviors")
@export var has_behavior:bool = false
@export var behavior_keys:Array[BaseBehavior.Type] = []
@export var has_btree:bool = false
@export var btree_nodes:Array = []

@export_group("Memory")
@export var has_memory:bool = false
@export var memory_focus_limit:int = 8
@export var vision_range:float = 5.0 * REG.SCALE
@export var vision_width:float = 2.0 * REG.SCALE

@export_group("Item")
@export var is_item:bool = false
@export var item_class:ITEMSTORE.ItemClass = ITEMSTORE.ItemClass.NONE
@export var drops:Array[ITEMSTORE.ItemClass] = []
