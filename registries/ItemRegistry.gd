## Central registry for item entities.
## Tracks item locations (world vs owned) and manages transfers.
class_name ItemRegistry
extends BaseRegistry

## All items by their UID
var _items:Dictionary[int, ItemComponent] = {}
## Items currently on the ground: position -> Array[uid]
var _world_items:Dictionary[Vector2i, Array] = {}
## Items owned by entities: owner_uid -> Array[uid]
var _owned_items:Dictionary[int, Array] = {}

## Register an item component
func register_item(uid:int, item:ItemComponent)->void:
	_items[uid] = item
	_update_location_index(uid, item)
## Remove item from registry (when entity destroyed)
func unregister_item(uid:int)->void:
	var item:ItemComponent = _items.get(uid)
	if not item: return
	
	_remove_from_location_index(uid, item)
	_items.erase(uid)
## Transfer item from world/owner to new owner
## Returns true if successful
func transfer_to_owner(item_uid:int, new_owner_uid:int)->bool:
	var item:ItemComponent = _items.get(item_uid)
	if not item: return false
	
	# Remove from old location
	_remove_from_location_index(item_uid, item)
	
	# Update ownership
	item.previous_owner_uid = item.owner_uid
	item.owner_uid = new_owner_uid
	
	# Add to new owner's inventory
	if not _owned_items.has(new_owner_uid):
		_owned_items[new_owner_uid] = []
	_owned_items[new_owner_uid].append(item_uid)
	
	return true
## Drop item to world position
## Returns true if successful
func drop_to_world(item_uid:int, position:Vector2)->bool:
	var item:ItemComponent = _items.get(item_uid)
	if not item: return false
	
	# Remove from old location
	_remove_from_location_index(item_uid, item)
	
	# Update to world state
	item.previous_owner_uid = item.owner_uid
	item.owner_uid = -1
	item.world_position = position
	
	# Add to world index
	var grid_pos:Vector2i = Vector2i(position)
	if not _world_items.has(grid_pos):
		_world_items[grid_pos] = []
	_world_items[grid_pos].append(item_uid)
	
	return true
## Get all items at a world position
func get_items_at_position(position:Vector2)->Array[int]:
	var grid_pos:Vector2i = Vector2i(position)
	var result:Array[int] = []
	var items:Array = _world_items.get(grid_pos, [])
	for uid in items:
		result.append(uid)
	return result
## Get all items owned by an entity
func get_owned_items(owner_uid:int)->Array[int]:
	var result:Array[int] = []
	var items:Array = _owned_items.get(owner_uid, [])
	for uid in items:
		result.append(uid)
	return result
## Internal: Update location indices when item moves
func _update_location_index(uid:int, item:ItemComponent)->void:
	if item.owner_uid == -1:
		# Item is on ground
		var grid_pos:Vector2i = Vector2i(item.world_position)
		if not _world_items.has(grid_pos):
			_world_items[grid_pos] = []
		_world_items[grid_pos].append(uid)
	else:
		# Item is owned
		if not _owned_items.has(item.owner_uid):
			_owned_items[item.owner_uid] = []
		_owned_items[item.owner_uid].append(uid)
## Internal: Remove item from location indices
func _remove_from_location_index(uid:int, item:ItemComponent)->void:
	if item.owner_uid == -1:
		# Remove from world
		var grid_pos:Vector2i = Vector2i(item.world_position)
		if _world_items.has(grid_pos):
			_world_items[grid_pos].erase(uid)
			if _world_items[grid_pos].is_empty():
				_world_items.erase(grid_pos)
	else:
		# Remove from owner
		if _owned_items.has(item.owner_uid):
			_owned_items[item.owner_uid].erase(uid)
			if _owned_items[item.owner_uid].is_empty():
				_owned_items.erase(item.owner_uid)
