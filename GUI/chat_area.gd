extends PanelContainer


@onready var default_pic = %pic.texture.duplicate(true)
const CHAT_BUBBLE = preload("res://GUI/chat_bubble.tscn")

func _ready():
	GlobalState.currentChatChanged.connect(on_current_change)
	GlobalState.userOnline.connect(online)
	on_current_change()

func online(ip,pic) -> void:
	if ip == GlobalState.currentChat:
		%status.text = "Online"
		if pic != null:
			%pic.texture = pic
		else:
			%pic.texture = default_pic
	
func  on_current_change() -> void:
	if GlobalState.currentChat.is_empty():
		visible = false
		return
	visible = true
	%Chatbox.text = ""
	%status.text = "Offline"
	for profile in GlobalState.usingDB.get_contacts():
		if profile["contactIP"] == GlobalState.currentChat:
			if profile["username"].is_empty():
				%username.text = "Unnamed Contact"
			else:
				%username.text = profile["username"]
			if profile["profile_pic"] != null:
				%pic.texture = profile["profile_pic"]
			else:
				%pic.texture = default_pic
	rebuild_messages()
	GlobalState.usingDB.read_messages(GlobalState.currentChat)

func on_new_message(message:Message) -> void:
	if message.origin_ip != GlobalState.currentChat and message.origin_ip != GlobalState.myIP : return
	var new_chat = CHAT_BUBBLE.instantiate()
	new_chat.on_right = (GlobalState.myIP == message.origin_ip)
	new_chat.text = str(message.data)
	%Chats.add_child(new_chat)
	%ScrollContainer.ensure_control_visible(new_chat)

func rebuild_messages() -> void:
	for child in %Chats.get_children():
		%Chats.remove_child(child)
	var messages = GlobalState.usingDB.get_message(GlobalState.currentChat)
	for message in messages:
		on_new_message(message["message"])

func _on_send_pressed():
	if %Chatbox.text.is_empty(): return
	var send_message: Message = Message.make_text(%Chatbox.text)
	var err:Error = GlobalState.P2P.send_message(GlobalState.currentChat,send_message)
	if err == OK:
		on_new_message(send_message)
		%Chatbox.text = ""
