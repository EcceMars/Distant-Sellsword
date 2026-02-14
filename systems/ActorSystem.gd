class_name ActorSystem
extends BaseSystem

var MOV_SYS:MovementSystem = null
var actors:Array = []

func _init(REG:REGISTRY)->void:
	REG.CANVAS.get_window().connect("window_input", handle_input)
func handle_input(event:InputEvent)->void:
	if event is InputEventKey:
		for actor:ActorComponent in actors:
			actor.a_button = event.keycode
	if event is InputEventMouseButton:
		for actor:ActorComponent in actors:
			actor.m_buttorn = event.button_index
func process(REG:REGISTRY)->void:
	for actor:ActorComponent in actors:
		if actor.a_button == KEY_CTRL and actor.m_buttorn:
			MOV_SYS.queue_move(actor.uid, REG.CANVAS.get_viewport().get_mouse_position(), REG)
		elif actor.m_buttorn:
			MOV_SYS.force_move(actor.uid, REG.CANVAS.get_viewport().get_mouse_position(), REG)
		if not Input.is_anything_pressed():
			actor.clear()
## Updates the [actors] array with the currrent registered [ActorComponent].
## This should occasionally be called to keep the [actors] up to the current population.
func scan_for_actors(REG:REGISTRY)->void:
	actors = REG.get_all_components_of(ACTOR_FLAG)
