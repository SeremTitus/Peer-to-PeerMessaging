extends Node

signal myIPChanged
signal myContactsChanged
signal currentChatChanged

signal new_message(message)
signal userOnline(IpString:String,pic: Texture2D)

var myIP:String:
	set(value):
		myIP = value
		currentChat = ""
		myIPChanged.emit()

var currentChat:String:
	set(value):
		currentChat = value
		currentChatChanged.emit()

var usingDB:dbHandler = dbHandler.new()
var P2P: P2PManager = P2PManager.new()

var verifiedIPs: Array = []:
	set(value):
		verifiedIPs = value
		if not myIP.is_empty(): return
		for profile in GlobalState.usingDB.get_profiles():
			if profile["myIP"] in verifiedIPs:
				myIP = profile["myIP"]

func _ready():
	add_child(P2P)
	userOnline.connect(update_pic)
	P2P.respondingIP.connect(func(x) :
		verifiedIPs.append(x)
		verifiedIPs = verifiedIPs
		)
	P2P.get_responding_IP(generate_myIP())

func _process(_delta):
	while len(P2P.new_messages) > 0:
		var message: Message = P2P.new_messages.pop_at(0)
		myContactsChanged.emit()
		new_message.emit(message)
	while len(P2P.new_online) > 0:
		var item = P2P.new_online.pop_at(0)
		userOnline.emit(item[0],item[1])
		
func update_pic(ip,pic) -> void:
	usingDB.update_contact(ip,"",pic)

func generate_myIP() -> Array:
	var goodIP: Array = []
	for ip in IP.get_local_addresses():
		if ip == "127.0.0.1" or len(ip.split(".")) != 4: continue
		goodIP.append(ip)
	return goodIP
