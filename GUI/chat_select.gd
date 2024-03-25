extends PanelContainer

@export var contactIP:String:
	set(value):
		contactIP = value

@onready var pic = %pic

func _ready():
	%username.text = ""
	%Preview.text = ""
	%date.text = ""
	%unreadcount.text = ""
	setup_info()
	GlobalState.userOnline.connect(online)
	GlobalState.currentChatChanged.connect(on_change_current)
	_on_timer_check_online_timeout()
	on_change_current()
	

func setup_info() -> void:
	for profile in GlobalState.usingDB.get_contacts():
		if profile["contactIP"] == contactIP:
			if profile["username"].is_empty():
				%username.text = "Unnamed Contact"
			else:
				%username.text = profile["username"]
			if profile["profile_pic"] != null:
				%pic.texture = profile["profile_pic"]
			var count_unread:int = 0
			var last_message: DateTime
			for message in GlobalState.usingDB.get_message(contactIP):
				if message["read_status"] == 0:
					count_unread += 1
				if last_message == null:
					last_message = message["message"].time_stamp
					continue
				if not message["message"].time_stamp.is_lesser(last_message):
					last_message = message["message"].time_stamp
					%Preview.text = message["message"].data
			%unreadcount.text = "" if count_unread <= 0 else str(count_unread)
			if last_message != null:
				%date.text = str(int(last_message.day)) +"/"+ str(int(last_message.month)) +"/" + str(int(last_message.year))

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == 1:
			GlobalState.currentChat = contactIP
		elif event.button_index == 2:
			%menu.popup()

func on_change_current():
	var new_style =get_theme_stylebox("panel").duplicate(true)
	if GlobalState.currentChat == contactIP:
		new_style.bg_color = Color("#38214e")
		%unreadcount.text = ""
	else:
		new_style.bg_color = Color("#2e2e2e")
	add_theme_stylebox_override("panel",new_style)
	

func _on_timer_check_online_timeout():
	var new_style = get_theme_stylebox("panel").duplicate(true)
	new_style.set_border_width_all(0)
	add_theme_stylebox_override("panel",new_style)
	GlobalState.P2P.request_check_online(contactIP)

func online(ip,set_pic):
	if ip == contactIP:
		if set_pic != null:
			pic.texture = set_pic
		var new_style = get_theme_stylebox("panel").duplicate(true)
		new_style.set_border_width_all(2)
		add_theme_stylebox_override("panel",new_style)
		setup_info()


func _on_window_about_to_popup():
	%menu.position =Vector2(position.x+300,position.y+150)
	%username2.text = %username.text


func _on_menu_close_requested():
	%menu.hide()

func _on_delete_pressed():
	print(GlobalState.usingDB.delete_contact(contactIP))
	GlobalState.myContactsChanged.emit()
