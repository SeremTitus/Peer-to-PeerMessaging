extends Window

var pic_changed:bool = false
func _on_profile_rect_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		%FileDialog.popup()

func _on_about_to_popup():
	%IPLabel.text = GlobalState.generate_myIP()[0]


func _on_save_pressed():
	var pic:Resource
	if pic_changed:
		pic = %icon.texture
	GlobalState.usingDB.add_profile(%IPLabel.text,%username.text,pic)
	GlobalState.myIP =  %IPLabel.text
	self.hide()

func _on_file_dialog_file_selected(path):
	var new_texture:Texture2D = load(path)
	if new_texture != null:
		%icon.texture = new_texture
		pic_changed = true
