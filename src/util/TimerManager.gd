extends Node

class_name TimerManager

var timers: Dictionary = {}
var timer_stopped: Dictionary = {}

func is_running(timer_name: String):
	return timer_stopped[timer_name]

func set_timer_status(timer_name: String):
	print("set timer " + timer_name + " to false")
	timer_stopped[timer_name] = false

func create_timer(timer_name: String, timer_duration: float):
	print("created timer " + timer_name + " with duration " + str(timer_duration))
	timers[timer_name] = Timer.new()
	add_child(timers[timer_name])
	timers[timer_name].one_shot = true;
	timers[timer_name].wait_time = timer_duration;
	timers[timer_name].timeout.connect(set_timer_status.bind(timer_name))
	timer_stopped[timer_name] = false
	
func start_timer(timer_name: String):
	print("started timer: " + timer_name)
	timers[timer_name].start()
	timer_stopped[timer_name] = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
