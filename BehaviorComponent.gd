class_name BehaviorComponent
extends BaseComponent

enum State { IDLE, WANDER, FLEE, REST, SEEK_FOOD }
var current:State = State.IDLE
var dying:float = 0.3
var hungry:float = 0.3
var tired:float = 0.2
