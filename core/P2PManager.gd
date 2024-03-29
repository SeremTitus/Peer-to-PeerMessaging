class_name P2PManager extends Node

signal respondingIP(ip:String)
var new_messages:Array =[]
var new_online: Array = []

const UDP_port:int = 24524
var address:String = "*"

var server:UDPServer = UDPServer.new()
var peers:Array[PacketPeerUDP] = []
var process:bool = true

func _ready():
	start_listening()

func _init(new_address:String = "*") -> void:
	address = new_address
	
func _process(_delta):
	if not process:
		return
	server.poll()
	if server.is_connection_available():
		var peer:PacketPeerUDP = server.take_connection()
		get_message(peer)
		peers.append(peer)
	for peer in peers:
		get_message(peer)

func get_message(peer:PacketPeerUDP) -> void:
	if not peer.is_socket_connected():
		peers.remove_at(peers.bsearch(peer))
	var packet_str:String = peer.get_packet().get_string_from_utf8()
	if packet_str.is_empty(): return
	var json:JSON = JSON.new()
	var error:Error = json.parse(packet_str)
	if error == OK:
		var message: Message = Message.from_json(json)
		var key:CryptoKey
		for profile in GlobalState.usingDB.get_profiles():
			if GlobalState.myIP == profile["myIP"]:
				key = profile["crypto_key"]
		message.decrypt(key)
		GlobalState.usingDB.update_contact(message.origin_ip,"",null,message.origin_pubkey)
		if message.is_system_message:
			handle_system(message)
		else:
			if message.origin_ip == GlobalState.myIP: return
			GlobalState.usingDB.add_contact(message.origin_ip,message.origin_username,null,message.origin_pubkey)
			GlobalState.usingDB.save_message(peer.get_packet_ip(),message)
			new_messages.append(message)

func send_message(recieveAddress: String, message:Message) -> Error:
	if message == null or recieveAddress.is_empty() : return FAILED
	var key:CryptoKey
	for profile in GlobalState.usingDB.get_contacts():
		if recieveAddress == profile["contactIP"]:
			key = profile["crypto_key"]
	message.encrypt(key)
	var err:Error
	for peer in peers:
		if not peer.is_socket_connected():
			peers.remove_at(peers.bsearch(peer))
			continue
		if peer.get_packet_ip() == recieveAddress:
			err = peer.put_packet(JSON.stringify(message.to_json().data).to_utf8_buffer())
			if err == OK and not message.is_system_message:
				GlobalState.usingDB.save_message(recieveAddress,message)
			return err
	var udp := PacketPeerUDP.new()
	err = udp.connect_to_host(recieveAddress, UDP_port)
	if err != OK: return err
	err = udp.put_packet(JSON.stringify(message.to_json().data).to_utf8_buffer())
	if err == OK:
		if not message.is_system_message:
			GlobalState.usingDB.save_message(recieveAddress,message)
		peers.append(udp)
	return err
	
func start_listening() -> void:
	server.listen(UDP_port)
	process = true

func stop_listening() -> void:
	server.stop()
	process = false

func request_check_online(IPaddress: String) -> void:
	send_message(IPaddress,Message.make_system("online",null))
	
func get_responding_IP(ips:Array) -> void:
	for ip in ips:
		var message:Message = Message.make_system("respondingIP",null)
		message.origin_ip = ip
		send_message(ip,message)

func handle_system(message:Message) -> void:
	if message.command == "online":
		if not message.data.is_empty():
			var data = Marshalls.base64_to_variant(message.data,true)
			new_online.append([message.origin_ip,data["pic"]])
	if message.command == "respondingIP":
		respondingIP.emit(message.origin_ip)
