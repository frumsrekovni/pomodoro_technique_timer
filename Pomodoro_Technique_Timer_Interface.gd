extends Control


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
onready var save_file_name = "subjects/no subject"
onready var dark_mode = false
onready var silent_mode = false
var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$work_time_input_buffer.grab_focus()
	save_file.open(save_file_name,File.READ)
	$saved_subjects_options.add_item("no subject")
	
	var dir = Directory.new()
	dir.open("subjects")
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if(!file_name.begins_with(".")):
			$saved_subjects_options.add_item(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	save_file.open(save_file_name,File.READ)
	$total_time_overall_value.text = str((int(save_file.get_as_text()) / 1000)/60)
	save_file.close()
	
	if(time_to_work):
		main_timer_in_minutes = ("%03d"%(work_time.time_left / 60))
		$main_timer_displayer_seconds.text = str("%02d"%(int(work_time.time_left)%60))
		$main_timer_displayer.text = str(main_timer_in_minutes)
		
		time_now=OS.get_ticks_msec()
		total_work_time_this_session=(time_now - time_start)
		save_file.open(save_file_name,File.WRITE)
		save_file.store_line(to_json(total_work_time_overall+total_work_time_this_session))
		save_file.close()
		
		if(work_time.is_stopped()):
			time_to_work = false
			_Darkmode_enabled_change_text(dark_mode, " REST")
			time_for_break = true
			break_time.set_wait_time(rest_time_minutes_in_seconds)
			total_work_time_overall += total_work_time_this_session
			save_file.open(save_file_name,File.WRITE)
			save_file.store_line(to_json(total_work_time_overall))
			save_file.close()
			
			_request_attention()
			$beep.play()
			break_time.start()
	elif(time_for_break):
		main_timer_in_minutes = ("%03d"%(break_time.time_left / 60))
		$main_timer_displayer_seconds.text = str("%02d"%(int(break_time.time_left)%60))
		$main_timer_displayer.text = str(main_timer_in_minutes)
		if(break_time.is_stopped()):
			time_to_work = true
			time_for_break = false
			_Darkmode_enabled_change_text(dark_mode," WORK")
			work_time.set_wait_time(work_time_minutes_in_seconds)
			_request_attention()
			$beep.play()
			work_time.start()
			time_start = OS.get_ticks_msec()
			
	
	if($start_button_error_prompt.visible):
		print($start_button_error_prompt.modulate.a)
		$start_button_error_prompt.modulate.a -= 0.004
		if($start_button_error_prompt.modulate.a <= 0):
			
			$start_button_error_prompt.visible=false
			$start_button_error_prompt.modulate.a = 1
	
	if(save_file_name == "subjects/malte every friday"):
		rng.randomize()
		VisualServer.set_default_clear_color(Color(rng.randf_range(0,1),rng.randf_range(0,1),rng.randf_range(0,1),1.0))	
	

func _on_TextureButton_pressed() -> void:
	$work_time_input_buffer.grab_focus()
	work_time_minutes_in_seconds = float($work_time_input_buffer.text)*60
	rest_time_minutes_in_seconds = float($break_time_input_buffer.text)*60
	if(_accepted_value_check(str($work_time_input_buffer.text)) && _accepted_value_check(str($break_time_input_buffer.text))):
		work_time.set_wait_time(work_time_minutes_in_seconds)
		break_time.set_wait_time(rest_time_minutes_in_seconds)
		work_time.start()
		time_start = OS.get_ticks_msec()
		time_to_work = true
		time_for_break = false
	else:
		$start_button_error_prompt.visible = true
	
	_Darkmode_enabled_change_text(dark_mode," WORK")

func _on_Work_timer_timeout() -> void:
	work_time.stop()
	


func _on_LineEdit_text_entered(new_text: String) -> void:
	work_time.set_wait_time(int(new_text))
	

func _on_Break_timer_timeout() -> void:
	break_time.stop()


func _on_work_time_input_buffer_text_changed(new_text: String) -> void:
	if(_accepted_value_check(new_text)):
		$work_time_label.bbcode_text = ("[color=green]"+$work_time_label.text+"[/color]")
	else:
		$work_time_label.bbcode_text = ("[color=red]"+$work_time_label.text+"[/color]")
	


func _on_break_time_input_buffer_text_changed(new_text: String) -> void:
	if(_accepted_value_check(new_text)):
		$break_time_label.bbcode_text = ("[color=green]"+$break_time_label.text+"[/color]")
	else:
		$break_time_label.bbcode_text = ("[color=red]"+$break_time_label.text+"[/color]")
	

func _on_Reset_pressed() -> void:
	total_work_time_overall = 0
	total_work_time_this_session = 0
	time_to_work = false
	time_for_break = false
	work_time_minutes_in_seconds= 0
	rest_time_minutes_in_seconds= 0
	
	work_time.set_wait_time(1)
	break_time.set_wait_time(1)
	main_timer_in_minutes = 0
	$main_timer_displayer_seconds.text = str("%02d"%(int(main_timer_in_minutes)%60))
	$main_timer_displayer.text = str("%03d"%main_timer_in_minutes)
	$break_time_input_buffer.clear()
	$work_time_input_buffer.clear()
	$subject_input.text = "no subject"
	_open_or_create_new_file("no subject")
	
	
func _accepted_value_check(value: String):
	var x = float(value)
	if((x < 1000) && (x > 0.0) && (value.is_valid_float())):
		return true
	else:
		return false
	

func _open_or_create_new_file(file_name: String):
	save_file_name = "subjects/"+file_name.to_lower()
	save_file.open(file_name,File.READ)
	total_work_time_overall = int(save_file.get_as_text())
	save_file.close()

func _on_subject_input_text_entered(new_text_input: String) -> void:
	_open_or_create_new_file(new_text_input)
	$total_time_overall_value.text = str((int(save_file.get_as_text()) / 1000)/60)
	$TextureButton.grab_focus()

# When selecting an option in the drop down menu the subject's file will be opened 
# in order to read its total time and add to it
func _on_saved_subjects_options_item_selected(index: int) -> void:
	$subject_input.text = $saved_subjects_options.get_item_text(index)
	_open_or_create_new_file($saved_subjects_options.get_item_text(index))



func _on_work_time_input_buffer_text_entered(new_text: String) -> void:
	$break_time_input_buffer.grab_focus()


func _on_break_time_input_buffer_text_entered(new_text: String) -> void:
	$subject_input.grab_focus()


func _on_subject_input_focus_entered() -> void:
	$subject_input.select_all()

func _Darkmode_enabled_change_text(enabled: bool, text: String) -> void:
	if(enabled):
		$current_status.bbcode_text = ("[color=black]"+text+"[/color]")
	else:
		$current_status.bbcode_text = ("[color=white]"+text+"[/color]")

func _on_Darkmode_button_toggled(button_pressed: bool) -> void:
	if(button_pressed):
		#Darkmode ON
		dark_mode = button_pressed
		VisualServer.set_default_clear_color(Color(0.09,0.09,0.09,1.0))
		$main_timer_displayer.get("custom_fonts/normal_font").outline_color = Color(0.98,0.98,0.98,1.0)
		$current_status.bbcode_text = ("[color=black]"+$current_status.text+"[/color]")
		$current_status.get("custom_fonts/normal_font").outline_color = Color(0.98,0.98,0.98,1.0)
		$mins.bbcode_text = ("[color=white](min)[/color]")
	else:
		dark_mode = button_pressed
		VisualServer.set_default_clear_color(Color(0.95,0.95,0.95,1.0))
		$main_timer_displayer.get("custom_fonts/normal_font").outline_color = Color(0,0,0,1.0)
		$current_status.get("custom_fonts/normal_font").outline_color = Color(0,0,0,1.0)
		$current_status.bbcode_text = ("[color=white]"+$current_status.text+"[/color]")
		$mins.bbcode_text = ("[color=black](min)[/color]")

func _on_Silentmode_button_toggled(button_pressed: bool) -> void:
	if(button_pressed):
		#Silentmode ON
		silent_mode = true
		$beep.set_stream_paused(true)
	else:
		silent_mode = false
		$beep.set_stream_paused(false)

func _request_attention() -> void:
	if(silent_mode):
		OS.request_attention()


func _on_delete_button_pressed() -> void:
	$ConfirmationDeleteSubject.popup()

func _on_ConfirmationDeleteSubject_confirmed() -> void:
	var dir = Directory.new()
	dir.remove(save_file_name)
	$saved_subjects_options.remove_item($saved_subjects_options.get_selected_id())
	_on_Reset_pressed()
