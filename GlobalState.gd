extends Node

signal myIPChanged
signal myContactsChanged
signal currentChatChanged

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
	P2P.new_online.connect(func(ip,pic):usingDB.update_contact(ip,"",pic))
	P2P.respondingIP.connect(func(x) :
		verifiedIPs.append(x)
		verifiedIPs = verifiedIPs
		)
	P2P.new_message.connect(func(_message): myContactsChanged.emit())
	P2P.get_responding_IP(generate_myIP())

func generate_myIP() -> Array:
	var goodIP: Array = []
	for ip in IP.get_local_addresses():
		if ip == "127.0.0.1" or len(ip.split(".")) != 4: continue
		goodIP.append(ip)
	return goodIP
