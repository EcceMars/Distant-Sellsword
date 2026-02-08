class_name ControllerSystem
extends System

var controller:ControllerComponent = null
func handler(event:InputEvent)->void:
	if event is InputEventKey:
		controller.a_button = event.keycode
	if event is InputEventMouseButton:
		controller.m_button = event.button_index
func _init(WORLD:ECS_MANAGER, _controller:ControllerComponent)->void:
	controller = _controller
	controller.monitor.get_window().connect("window_input", handler)
	var msid:int = WORLD.systems.find_custom(func(a): return a is MovementSystem)
	controller.sys = WORLD.systems[msid]
func process(_WORLD:ECS_MANAGER)->void:
	if controller.a_button == KEY_CTRL and controller.m_button:
		controller.sys.queue_move(controller.entity, controller.monitor.get_viewport().get_mouse_position())
	elif controller.m_button:
		controller.sys.force_move(controller.entity, controller.monitor.get_viewport().get_mouse_position())
	if not Input.is_anything_pressed():
		clear()
func clear()->void:
	controller.a_button = 0
	controller.m_button = 0
	#TODO: If later on, there's a need to use the arrowkeys
	controller.axis = Vector2.ZERO
