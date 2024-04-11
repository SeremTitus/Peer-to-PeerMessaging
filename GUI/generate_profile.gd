extends Window

var pic_changed:bool = false

var available_ips: Array[String] = []:
	set(value):
		available_ips = value
		btn_visibility()

func _ready():
	%IPLabel.text = ""
	GlobalState.P2P.respondingIP.connect( func(x):
		if not available_ips.has(x):
			available_ips.append(x)
		if %IPLabel.text.is_empty():
			%IPLabel.text = x
		available_ips = available_ips
	)
	GlobalState.myIPChanged.connect(func():
		if GlobalState.myIP == "":
			self.show()
		else:
			self.hide())
	btn_visibility()

func _on_profile_rect_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		%FileDialog.popup()

func next_ip(right:bool):
	if not %IPLabel.text.is_empty():
		var pst = available_ips.find(%IPLabel.text)
		if right and pst < len(available_ips) - 1:
			pst += 1
			%IPLabel.text = available_ips[pst]
		elif not right and pst > 0:
			pst -= 1
			%IPLabel.text = available_ips[pst]
		btn_visibility()

func  btn_visibility():
	if not %IPLabel.text.is_empty():
		var pst = available_ips.find(%IPLabel.text)
		if pst >= len(available_ips) -1:
			%right.visible = false
		if pst <= 0:
			%left.visible = false
		if pst < len(available_ips) - 1:
			%right.visible = true
		if pst > 0:
			%left.visible = true
	else:
		%right.visible = false
		%left.visible = false
	
func _on_about_to_popup():
	%IPLabel.text = ""
	%username.text = ""
	available_ips.clear()
	GlobalState.P2P.get_responding_IP(GlobalState.generate_myIP())
	btn_visibility()

func _on_save_pressed():
	var pic:Resource
	if pic_changed:
		pic = %icon.texture
	if %IPLabel.text.is_empty() and  not available_ips.is_empty():
			%IPLabel.text = available_ips[0]
	GlobalState.usingDB.add_profile(%IPLabel.text,%username.text,pic)
	self.hide()
	GlobalState.myIP =  %IPLabel.text

func _on_file_dialog_file_selected(path):
	var new_texture:Texture2D = load(path)
	if new_texture != null:
		%icon.texture = new_texture
		pic_changed = true
