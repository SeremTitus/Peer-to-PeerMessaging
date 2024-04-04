extends Control

var count = 0
const CHAT_SELECT = preload("res://GUI/chat_select.tscn")

func _ready() -> void:
	%menu.hide()
	if GlobalState.myIP.is_empty(): $generateProfile.popup()
	GlobalState.myIPChanged.connect(setup_myHeader_info)
	GlobalState.myIPChanged.connect(setup_contact_select)
	GlobalState.myContactsChanged.connect(setup_contact_select)
	setup_myHeader_info()
	setup_contact_select()
	
func setup_myHeader_info() -> void:
	%IPLable.text = GlobalState.myIP
	for profile in GlobalState.usingDB.get_profiles():
		if profile["myIP"] == GlobalState.myIP and profile["profile_pic"] != null:
			%mypic.texture = profile["profile_pic"]

func setup_contact_select() -> void:
	for child in %ChatsContainer.get_children():
		%ChatsContainer.remove_child(child)
	for profile in GlobalState.usingDB.get_contacts():
		var new_child = CHAT_SELECT.instantiate()
		new_child.contactIP = profile["contactIP"]
		%ChatsContainer.add_child(new_child)


func _on_mypic_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 2:
		%menu.popup()

func _on_menu_close_requested():
	%menu.hide()

func _on_delete_pressed():
	if GlobalState.usingDB.delete_profile(GlobalState.myIP) == OK:
		GlobalState.myIP = ""
		%menu.hide()
