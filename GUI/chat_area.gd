extends PanelContainer


@onready var default_pic = %pic.texture.duplicate(true)
const CHAT_BUBBLE = preload("res://GUI/chat_bubble.tscn")
var offlineTimer: Timer = Timer.new()

func _ready():
	GlobalState.currentChatChanged.connect(on_current_change)
	GlobalState.P2P.new_online.connect(online)
	GlobalState.P2P.new_message.connect(on_new_message)
	on_current_change()
	offlineTimer.autostart = true
	offlineTimer.wait_time =10
	offlineTimer.timeout.connect(func(): %status.text = "Offline")
	add_child(offlineTimer)

func online(ip,pic) -> void:
	if ip == GlobalState.currentChat:
		offlineTimer.stop()
		offlineTimer.start()
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
	GlobalState.usingDB.read_messages(GlobalState.currentChat)
	var new_chat = CHAT_BUBBLE.instantiate()
	new_chat.on_right = (GlobalState.myIP == message.origin_ip)
	new_chat.text = str(message.data)
	%Chats.add_child(new_chat)
	%ScrollContainer.set_deferred("scroll_vertical", (%ScrollContainer.scroll_vertical + 10) * 5000)

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
