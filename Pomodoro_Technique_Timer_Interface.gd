extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var work_time = get_node("Work_timer")
onready var break_time = get_node("Break_timer")
onready var main_timer_in_minutes = 0
onready var time_to_work = false
onready var time_for_break = false
onready var work_time_minutes_in_seconds= 0
onready var rest_time_minutes_in_seconds= 0
onready var total_work_time_this_session= 0
onready var total_work_time_overall= 0
onready var time_start= 0
onready var time_now= 0
onready var save_file = File.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	work_time.set_wait_time(0)
	break_time.set_wait_time(0)
	save_file.open("total_time_studied",File.READ)
	total_work_time_overall = int(save_file.get_as_text())
	save_file.close()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	save_file.open("total_time_studied",File.READ)
	#print((int(save_file.get_as_text())/1000)/60)
	$total_time_overall_value.text = str((int(save_file.get_as_text()) / 1000)/60)
	save_file.close()
	if(time_to_work):
		$current_status.text = "WORK"
		main_timer_in_minutes = ("%03d"%(work_time.time_left / 60))
		$main_timer_displayer_seconds.text = str("%02d"%(int(work_time.time_left)%60))
		$main_timer_displayer.text = str(main_timer_in_minutes)
		
		time_now=OS.get_ticks_msec()
		total_work_time_this_session=(time_now - time_start)
		save_file.open("total_time_studied",File.WRITE)
		save_file.store_line(to_json(total_work_time_overall+total_work_time_this_session))
		save_file.close()
		
		if(work_time.is_stopped()):
			time_to_work = false
			time_for_break = true
			break_time.set_wait_time(rest_time_minutes_in_seconds)
			#break_time.set_wait_time(5)
			total_work_time_overall += total_work_time_this_session
			save_file.open("total_time_studied",File.WRITE)
			save_file.store_line(to_json(total_work_time_overall))
			save_file.close()
			$beep.play()
			break_time.start()
	elif(time_for_break):
		$current_status.text = "REST"
		main_timer_in_minutes = ("%03d"%(break_time.time_left / 60))
		$main_timer_displayer_seconds.text = str("%02d"%(int(break_time.time_left)%60))
		$main_timer_displayer.text = str(main_timer_in_minutes)
		if(break_time.is_stopped()):
			time_to_work = true
			time_for_break = false
			work_time.set_wait_time(work_time_minutes_in_seconds)
			#work_time.set_wait_time(5)
			$beep.play()
			work_time.start()
			time_start = OS.get_ticks_msec()
			
		
	

func _on_Button_pressed() -> void:
	work_time.start()
	time_start = OS.get_ticks_msec()
	time_to_work = true
	time_for_break = false

func _on_Work_timer_timeout() -> void:
	work_time.stop()
	


func _on_LineEdit_text_entered(new_text: String) -> void:
	work_time.set_wait_time(int(new_text))
	


func _on_break_time_input_buffer_text_entered(new_text: String) -> void:
	rest_time_minutes_in_seconds = int(new_text)*60
	break_time.set_wait_time(rest_time_minutes_in_seconds)
	#break_time.set_wait_time(5)
	$break_time_label.bbcode_text = ("[color=green]"+$break_time_label.text+"[/color]")


func _on_work_time_input_buffer_text_entered(new_text: String) -> void:
	work_time_minutes_in_seconds = int(new_text)*60
	work_time.set_wait_time(work_time_minutes_in_seconds)
	#work_time.set_wait_time(5)
	$work_time_label.bbcode_text = ("[color=green]"+$work_time_label.text+"[/color]")


func _on_Break_timer_timeout() -> void:
	break_time.stop()


func _on_work_time_input_buffer_text_changed(new_text: String) -> void:
	$work_time_label.bbcode_text = ("[color=red]"+$work_time_label.text+"[/color]")


func _on_break_time_input_buffer_text_changed(new_text: String) -> void:
	$break_time_label.bbcode_text = ("[color=red]"+$break_time_label.text+"[/color]")
