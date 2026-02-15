class_name AnimationStateComponent
extends BaseComponent

enum State {	IDLE, WALK, ACT, REST, ATTACK, DEATH	}

var current:State = State.IDLE
var previous:State = State.IDLE
var latency:float = 0.0

func _init()->void:
	flag = Flag.ANIMATION_STATE
func change(new_state:State)->void:
	if new_state != current:
		previous = current
		current = new_state
		latency = 0.0
