class_name P2PManager extends RefCounted

#for signal
var new_messages:Array =[]
var new_online: Array = []
#




const UDP_port:int = 24524
var address:String = "*"

var server:UDPServer = UDPServer.new()
var peers:Array[PacketPeerUDP] = []

var process_timer:TrueTimmer = TrueTimmer.new()
var process:bool = true

func _init(new_address:String = "*") -> void:
	address = new_address
	process_timer.timeout.connect(start_timer)
	start_listening()
	start_timer()

func  start_timer():
	process_tick()
	process_timer.start(1.0)

func process_tick() -> void:
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
		if message.is_system_message:
			handle_system(message)
		else:
			if message.origin_ip == GlobalState.myIP: return
			GlobalState.usingDB.save_message(message)
			new_messages.append(message)

func send_message(recieveAddress: String, message:Message) -> Error:
	if message == null or recieveAddress.is_empty() : return FAILED
	for peer in peers:
		if not peer.is_socket_connected():
			peers.remove_at(peers.bsearch(peer))
			continue
		if peer.get_packet_ip() == recieveAddress:
			var err:Error = peer.put_packet(JSON.stringify(message.to_json().data).to_utf8_buffer())
			if err == OK and not message.is_system_message:
				GlobalState.usingDB.save_message(message)
			return err
	var udp := PacketPeerUDP.new()
	udp.connect_to_host(recieveAddress, UDP_port)
	var err:Error = udp.put_packet(JSON.stringify(message.to_json().data).to_utf8_buffer())
	if err == OK:
		if not message.is_system_message:
			GlobalState.usingDB.save_message(message)
		peers.append(udp)
	return err
	
func start_listening() -> void:
	server.listen(UDP_port,address)
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
		

