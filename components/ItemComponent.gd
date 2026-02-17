## Component for item entities - tracks ownership and location state
class_name ItemComponent
extends BaseComponent

## Item type/category (e.g. "food", "wood", "stone")
var item_type:String = ""
## Current owner entity UID (-1 if on ground)
var owner_uid:int = -1
## Previous owner (for tracking transfers)
var previous_owner_uid:int = -1
## World position when on ground (only valid if owner_uid == -1)
var world_position:Vector2 = Vector2.ZERO

func _init(_item_type:String = "generic")->void:
	item_type = _item_type
	flag = Flag.ITEM
