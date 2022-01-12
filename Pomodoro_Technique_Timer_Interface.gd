extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var work_time = get_node("Work_timer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	work_time.set_wait_time(5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Time_remaining.text = str(work_time.time_left)

func _on_Button_pressed() -> void:
	work_time.start()
	print("Hello World!")

func _on_Work_timer_timeout() -> void:
	work_time.stop()
	


func _on_LineEdit_text_entered(new_text: String) -> void:
	work_time.set_wait_time(int(new_text))
	work_time.start()
	$LineEdit.clear()
