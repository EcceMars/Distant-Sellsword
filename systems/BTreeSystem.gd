class_name BTreeSystem
extends BaseSystem

func process()->void:
	for uid:int in REG.get_entities_by(BTREE_FLAG):
		var blackboard:Dictionary = {}
		var tree = REG.get_component(uid, BTREE_FLAG)
		
		if tree:
			tree.act(uid, blackboard)
