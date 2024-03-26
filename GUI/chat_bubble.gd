extends PanelContainer

@export var on_right:bool = false:
	set(value):
		on_right = value
		var new_style: StyleBoxFlat = get_theme_stylebox("panel").duplicate(true)
		if value:
			set_h_size_flags(Control.SIZE_SHRINK_END)
			new_style.bg_color = Color("#1b8ceb")
			new_style.corner_radius_bottom_left = 20
			new_style.corner_radius_bottom_right = 60
			new_style.corner_radius_top_left  = 20
			new_style.corner_radius_top_right = 0
			new_style.content_margin_left = 8
			new_style.content_margin_right = 50

		else:
			set_h_size_flags(Control.SIZE_SHRINK_BEGIN)
			new_style.bg_color = Color("#00a364")
			new_style.corner_radius_bottom_left = 60
			new_style.corner_radius_bottom_right = 20
			new_style.corner_radius_top_left = 0
			new_style.corner_radius_top_right = 20
			new_style.content_margin_left = 50
			new_style.content_margin_right = 8
			
		add_theme_stylebox_override("panel",new_style)
			

@export var view_all_lines:bool = false:
	set(value):
		view_all_lines = value
		text = text

@export var text: String = "":
	set(value):
		if value.is_empty():
			if %text:
				%text.text = value
			text = value
			return
		var new_text: String = ""
		var count = 0
		for i in value:
			if count == 66:
				count = 0
				new_text += "\n"
			new_text += i
			count += 1
		if %text:
			%text.text = new_text
		text = new_text
		

func _on_text_ready():
	text = text
