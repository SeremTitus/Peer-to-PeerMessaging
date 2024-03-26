extends Window

var pic_changed:bool = false

func _ready():
	GlobalState.P2P.respondingIP.connect( func(x):
		if %IPLabel.text.is_empty():
			%IPLabel.text = x
	)
	GlobalState.myIPChanged.connect(func():
		self.hide())

func _on_profile_rect_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		%FileDialog.popup()

func _on_about_to_popup():
	if not GlobalState.verifiedIPs.is_empty():
		%IPLabel.text = GlobalState.verifiedIPs[0]


func _on_save_pressed():
	var pic:Resource
	if pic_changed:
		pic = %icon.texture
	if %IPLabel.text.is_empty():
		if not GlobalState.verifiedIPs.is_empty():
			GlobalState.myIP = GlobalState.verifiedIPs[0]
			%IPLabel.text = GlobalState.myIP
	else:
		GlobalState.myIP =  %IPLabel.text
	GlobalState.usingDB.add_profile(%IPLabel.text,%username.text,pic)	
	self.hide()

func _on_file_dialog_file_selected(path):
	var new_texture:Texture2D = load(path)
	if new_texture != null:
		%icon.texture = new_texture
		pic_changed = true
