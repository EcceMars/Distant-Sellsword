## Handles the player's input.
class_name ActorSystem
extends BaseSystem

var CAM:Camera2D = null			## Direct [Camera2D] node. It will probably be updated to receive the camera's [Node2D] parent instead.
var CAM_TARGET:Vector2 = Vector2.ZERO	## Next position the [member CAM_NODE] should go to.

const cam_speed:float = 4.0				## [member CAM_NODE] base speed.
var cam_acc:float = 0					## [member CAM_NODE] acceleration.

const MOVE_THRESHOLD:float = 0.08
var button_delta:float = 0.0

func _init(CAM_NODE:Camera2D)->void:
	CAM = CAM_NODE
	CAM_TARGET = Vector2(REG.WIDTH, REG.HEIGHT) * REG.SCALE
	CAM.position = CAM_TARGET
func process()->void:
	var MOV_SYS:MovementSystem = REG.SYSTEMS.get("MovementSystem")
	for actor:ActorComponent in REG.get_all_components_of(ACTOR_FLAG):
		var movement:MovementComponent = REG.get_component(actor.uid, MOV_FLAG)
		
		if not MOV_SYS._check_movable(movement): continue
		var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if Input.is_action_just_released("wheel_down"):
			CAM.zoom -= Vector2.ONE * 0.1
		if Input.is_action_just_released("wheel_up"):
			CAM.zoom += Vector2.ONE * 0.1
		CAM.zoom = CAM.zoom.clamp(Vector2.ONE * 0.1, Vector2.ONE * 3)
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			var mouse_pos:Vector2 = CAM.get_canvas_transform().affine_inverse() * CAM.get_viewport().get_mouse_position()
			CAM_TARGET = mouse_pos
		if input_dir != Vector2.ZERO:
			button_delta = clampf(button_delta + REG.DELTA, 0.0, MOVE_THRESHOLD)
			if button_delta >= MOVE_THRESHOLD:
				MOV_SYS.add_move(actor.uid, input_dir, true)
		else:
			button_delta = 0.0
	move_cam_to(CAM_TARGET)
## Moves the camera to a certain position. [param target] can be used both for mouse input, as well as, cinematics (show a certain position, follow the player).
func move_cam_to(target:Vector2)->void:
	if CAM.position.distance_to(target) < 2.0:
		CAM.position = target
		cam_acc = 0
		return
	CAM.position = CAM.position.move_toward(target, cam_speed + cam_acc)
	#CAM.position = CAM.position.lerp(target, 0.15)
	cam_acc = clampf(cam_acc + 1.0, 0.0, cam_speed * 2)
