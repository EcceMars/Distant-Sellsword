class_name InformationComponent
extends BaseComponent

## Should display
var is_active:bool = false
## Control node reference
var panel_ref:Control = null
var containers:Dictionary[String, Control] = {}
## Holds RPG information
var id:ID = null

func _init(_name:String, _gender:String, _is_active:bool = false)->void:
	is_active = _is_active
	id = ID.new(_name, _gender)
	flag = Flag.INFORMATION
## RPG-esque information
class ID extends InformationComponent:
	var name:String = "noname"
	var gender:String = "Female":
		set(value):
			gender = "Male" if value == "Male" else "Female"
	var blood = null
	var energy = null
	var hunger = null
	var thirst = null
	var mental_state = null
	func _init(_name:String, _gender:String = "Female")->void:
		name = _name
		gender = _gender
