extends Window

@onready var line_edit = %LineEdit
@onready var status = %status
@onready var pic = %pic
const DEFAULT_PROFILE_PIC = preload("res://assets/DefaultProfilePic.jpeg")

func _ready():
	GlobalState.userOnline.connect(update_info)
	GlobalState.myIPChanged.connect(self.hide)

func update_info(ip,set_pic):
	if ip == line_edit.text: 
		status.text = "Online"
		if set_pic != null:
			pic.texture = set_pic

func _on_about_to_popup():
	%LineEdit.text = ""
	%Username.text = ""
	%pic.texture = DEFAULT_PROFILE_PIC

func _on_cancel_pressed():
	self.hide()

func _on_save_pressed():
	var username = %Username.text
	if %LineEdit.text == GlobalState.myIP:
		username = "ME"
	GlobalState.usingDB.add_contact(%LineEdit.text,username,%pic.texture)
	GlobalState.myContactsChanged.emit()
	self.hide()

func _on_line_edit_text_changed(ip: String):
	if ip == "127.0.0.1" or len(ip.split(".")) != 4:
		%Save.disabled = true
		%status.text = "Searching..."
		%pic.texture = DEFAULT_PROFILE_PIC
		return
	for i in ip.split("."):
		for j in str(i):
			if not j in ["1","2","3","4","5","6","7","8","9","0"]:
				%Save.disabled = true
				%status.text = "Searching..."
				%pic.texture = DEFAULT_PROFILE_PIC
				return
		if int(i) > 255 or str(i).is_empty():
			%Save.disabled = true
			%status.text = "Searching..."
			%pic.texture = DEFAULT_PROFILE_PIC
			return
	GlobalState.P2P.request_check_online(ip)
	%status.text = "Offline"
	%Save.disabled = false

