class_name P2PManager extends Node

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
	
func _process(delta):
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
	print(packet_str)
	print("2",peer.get_var(true))
	var json:JSON = JSON.new()
	var error:Error = json.parse(packet_str)
	if error == OK:
		var message: Message = Message.from_json(json)
		if message.is_system_message:
			handle_system(message)
		else:
			if message.origin_ip == GlobalState.myIP: return
			GlobalState.usingDB.save_message(peer.get_packet_ip(),message)
			new_messages.append(message)

func send_message(recieveAddress: String, message:Message) -> Error:
	if message == null or recieveAddress.is_empty() : return FAILED
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
	printerr(udp.connect_to_host(recieveAddress, UDP_port))
	err = udp.put_packet(JSON.stringify(message.to_json().data).to_utf8_buffer())
	if err == OK:
		if not message.is_system_message:
			GlobalState.usingDB.save_message(recieveAddress,message)
		peers.append(udp)
	return err
	
func start_listening() -> void:
	print(error_string(server.listen(UDP_port)))
	process = true

func stop_listening() -> void:
	server.stop()
	process = false
	
func request_check_online(IPaddress: String) -> void:
	send_message(IPaddress,Message.make_system("online",null))

func handle_system(message:Message) -> void:
	if message.command == "online":
		message.data = Marshalls.base64_to_variant(message.data,true)
		new_online.append([message.origin_ip,message.data["pic"]])
