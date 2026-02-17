## Handles the player's input.
class_name ActorSystem
extends BaseSystem

var CAM_NODE:Camera2D = null			## Direct [Camera2D] node. It will probably be updated to receive the camera's [Node2D] parent instead.
var CAM_TARGET:Vector2 = Vector2.ZERO	## Next position the [member CAM_NODE] should go to.
const cam_speed:float = 4.0				## [member CAM_NODE] base speed.
var cam_acc:float = 0					## [member CAM_NODE] acceleration.

func _init(CAM:Camera2D)->void:
	CAM_NODE = CAM
	CAM_TARGET = Vector2(REG.WIDTH, REG.HEIGHT) * REG.SCALE
	CAM_NODE.position = CAM_TARGET
	REG.CANVAS.get_window().connect("window_input", handle_input)
func handle_input(event:InputEvent)->void:
	if not (event is InputEventKey or event is InputEventMouseButton):
		return
func process()->void:
	var MOV_SYS:MovementSystem = REG.SYSTEMS.get("MovementSystem")
	for actor:ActorComponent in REG.get_all_components_of(ACTOR_FLAG):
		var movement:MovementComponent = REG.get_component(actor.uid, MOV_FLAG)
		
		if not MOV_SYS._is_eligible(movement): continue
		var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if Input.is_action_just_released("wheel_down"):
			CAM_NODE.zoom -= Vector2.ONE * 0.1
		if Input.is_action_just_released("wheel_up"):
			CAM_NODE.zoom += Vector2.ONE * 0.1
		CAM_NODE.zoom = CAM_NODE.zoom.clamp(Vector2.ONE * 0.1, Vector2.ONE * 3)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var mouse_pos:Vector2 = CAM_NODE.get_canvas_transform().affine_inverse() * CAM_NODE.get_viewport().get_mouse_position()
			CAM_TARGET = mouse_pos
		if input_dir != Vector2.ZERO:
			MOV_SYS.force_move(actor.uid, input_dir, true)
	move_cam_to(CAM_TARGET)
## Moves the camera to a certain position. [param target] can be used both for mouse input, as well as, cinematics (show a certain position, follow the player).
func move_cam_to(target:Vector2)->void:
	if CAM_NODE.position == target:
		cam_acc = 0
		return
	CAM_NODE.position = CAM_NODE.position.move_toward(target, cam_speed + cam_acc)
	cam_acc = clampf(cam_acc + 1.0, 0.0, cam_speed * 2)
