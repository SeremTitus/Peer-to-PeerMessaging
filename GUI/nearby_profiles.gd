extends Window

const CHAT_SELECT = preload("res://GUI/chat_select.tscn")
@onready var default_pic = %pic.texture.duplicate(true)


func _init():
	pass

func  add_find(ip: String, username: String, pic: Texture):
	var i = CHAT_SELECT.instantiate()
	var space = Control.new()
	space.custom_minimum_size = Vector2(300,0)
	space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	i.get_child(0).get_child(0).add_child(space)
	i.gui_input.disconnect(i._on_gui_input)
	i.gui_input.connect(
		func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == 1:
				%menu.hide()
				if pic != null:
					%pic.texture = pic
				else:
					%pic.texture = default_pic
				%username.text = username
				%ip.text = ip
				%menu.show()
	)
	
	i.notify_offline.connect(func(): %GridContainer.remove_child(i))
	i.notify_online.connect(func(): %GridContainer.add_child(i))
	%GridContainer.add_child(i)
	i.override(username,pic)

func _on_about_to_popup():
	pass

func _on_add_pressed():
	pass
