class_name StatsComponent
extends BaseComponent

var char_name:String = ""
var gender:String = "Female"

var blood:Vital
var energy:Vital
var hunger:Vital
var thirst:Vital

var is_alive:bool = true
var is_conscious:bool = true

func _init(
	_name:String = char_name,
	_gender:String = gender,
	
	blood_max:float = 100.0, b_reg:float = 0.1,
	energy_max:float = 100.0, e_reg:float = 0.5,
	hunger_max:float = 100.0, h_reg:float = -0.01,
	thirst_max:float = 100.0, t_reg:float = -0.02)->void:
	
	if not _name:
		char_name = REG.DATA.female_names.pick_random() if _gender == "Female" else REG.DATA.male_names.pick_random()
	else:
		char_name = _name
	gender = _gender
	
	blood = Vital.new(blood_max, blood_max, b_reg)		# Slow regen
	energy = Vital.new(energy_max, energy_max, e_reg)	# Faster regen when resting
	hunger = Vital.new(hunger_max, hunger_max, h_reg)	# Decays over time
	thirst = Vital.new(thirst_max, thirst_max, t_reg)	# Decays faster than hunger
	flag = Flag.STATS
func check_stats()->int:
	var DEAD:int = 0
	var UNCONSCIOUS:int = 1
	var HUNGRY:int = 2
	var THIRSTY:int = 3
	var DYING:int = 4
	var TIRED:int = 5
	var NORMAL:int = -1
	if blood:
		is_alive = blood.check_vital()
		if not is_alive:
			return DEAD
		if blood.check_vital(0.2): return DYING
	if energy:
		is_conscious = energy.check_vital()
		if not is_conscious:
			return UNCONSCIOUS
		if energy.check_vital(0.2):
			return TIRED
	if hunger:
		if hunger.check_vital(0.3): return HUNGRY
	if thirst:
		if thirst.check_vital(0.3): return THIRSTY
	return NORMAL
func _to_string()->String:
	var message:String = get_script().get_global_name()
	var list:Dictionary[String, float] = {}
	if blood: list["Blood"] = blood.ratio()
	if energy: list["Energy"] = energy.ratio()
	if hunger: list["Hunger"] = hunger.ratio()
	if thirst: list["Thrist"] = thirst.ratio()
	return message + str(list)
## Vital stats container
class Vital:
	var value:float
	var maximum:float
	var regen_factor:float
	
	func _init(_max:float, _current:float = 0.0, _regen:float = 0.0)->void:
		maximum = _max
		if maximum <= 0: maximum = 1.0
		value = _current
		regen_factor = _regen
	
	func is_depleted()->bool:
		return value <= 0
	func is_full()->bool:
		return value >= maximum
	func recover(amount:float)->void:
		value = clampf(value + abs(amount), value, maximum)
	func hurt(amount:float)->void:
		value = clampf(value - abs(amount), 0.0, value)
	func modify(amount:float)->void:
		value = clampf(value + amount, 0.0, maximum)
	func heal()->void:
		if not is_full():
			value += value * regen_factor
	func ratio()->float:
		return value / maximum
	func check_vital(threshold:float = 0.0)->bool:
		return ratio() <= threshold
