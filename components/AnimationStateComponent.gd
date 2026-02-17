## Holds animation state data.
class_name AnimationStateComponent
extends BaseComponent

## Currently implemented animation states
enum State {	IDLE, WALK	}

var current:State = State.IDLE
var previous:State = State.IDLE
var latency:float = 0.0		## EXPERIMENTAL: still unsure

func _init()->void:
	flag = Flag.ANIMATION_STATE
func change(new_state:State)->void:
	if new_state != current:
		previous = current
		current = new_state
		latency = 0.0
