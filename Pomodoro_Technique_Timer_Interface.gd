extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var work_time = get_node("Work_timer")
onready var break_time = get_node("Break_timer")
onready var time_to_work = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	work_time.set_wait_time(0)
	break_time.set_wait_time(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(time_to_work):
		$main_timer_displayer.text = str(work_time.time_left)
		if(work_time.is_stopped()):
			time_to_work = false
	
	

func _on_Button_pressed() -> void:
	work_time.start()
	time_to_work = true
	print("Hello World!")

func _on_Work_timer_timeout() -> void:
	work_time.stop()
	


func _on_LineEdit_text_entered(new_text: String) -> void:
	work_time.set_wait_time(int(new_text))
	


func _on_break_time_input_buffer_text_entered(new_text: String) -> void:
	break_time.set_wait_time(int(new_text))
	$break_time_label.bbcode_text = ("[color=green]"+$break_time_label.text+"[/color]")


func _on_work_time_input_buffer_text_entered(new_text: String) -> void:
	work_time.set_wait_time(int(new_text))
	$work_time_label.bbcode_text = ("[color=green]"+$work_time_label.text+"[/color]")


func _on_Break_timer_timeout() -> void:
	break_time.stop()


func _on_work_time_input_buffer_text_changed(new_text: String) -> void:
	$work_time_label.bbcode_text = ("[color=red]"+$work_time_label.text+"[/color]")


func _on_break_time_input_buffer_text_changed(new_text: String) -> void:
	$break_time_label.bbcode_text = ("[color=red]"+$break_time_label.text+"[/color]")
