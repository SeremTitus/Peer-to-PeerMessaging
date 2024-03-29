class_name Message extends RefCounted

var origin_ip: String = GlobalState.myIP:
	set(value):
		origin_ip =  value
		for profile in GlobalState.usingDB.get_profiles():
			if origin_ip == profile["myIP"]:
				origin_pubkey = e2ee.public_key_only(profile["crypto_key"])
				return

var origin_username: String
var origin_pubkey: CryptoKey
var time_stamp: DateTime = DateTime.now()
var data:String
var is_encryted = false

var is_system_message: bool = false
var command: String

func _init():
	for profile in GlobalState.usingDB.get_profiles():
			if profile["myIP"] in GlobalState.myIP:
				origin_username = profile["username"]

func  _to_string() -> String:
	var output: Dictionary = {
		"origin_ip": origin_ip,
		"origin_username" : origin_username,
		"is_system_message": is_system_message,
		"data": data,
		"time_stamp" : time_stamp,
		"command": command,
	}
	return str(output)

func to_json():
	var output: Dictionary = {
		"origin_ip": origin_ip,
		"origin_username":origin_username,
		"origin_pubkey": Marshalls.variant_to_base64(origin_pubkey,true),
		"is_system_message": is_system_message,
		"data": data,
		"is_encryted": is_encryted,
		"time_stamp" : {
						"year" : time_stamp.year,
						"month" : time_stamp.month,
						"weekday" : time_stamp.weekday,
						"day" : time_stamp.day,
						"hour" : time_stamp.hour,
						"minute" : time_stamp.minute,
						"second" : time_stamp.second,
						"microsecond": time_stamp.microsecond
						},
		"command": command,
	}
	var json = JSON.new()
	json.parse(JSON.stringify(output,"",true,true))
	return json

func encrypt(key:CryptoKey) -> void:
	if is_encryted or key == null or data.is_empty(): return
	var message: PackedByteArray = Marshalls.base64_to_raw(data)
	var encrypt_message = e2ee.encrypt(message,key)
	if not encrypt_message.is_empty():
		data = Marshalls.raw_to_base64(encrypt_message)
		is_encryted = true

func decrypt(key:CryptoKey) -> void:
	if not is_encryted or key == null or data.is_empty() or  key.is_public_only() or key.save_to_string().is_empty(): return
	var message = e2ee.decrypt(Marshalls.base64_to_raw(data),key)
	data = Marshalls.raw_to_base64(message)
	is_encryted = false

static func from_json(json:JSON) -> Message:
	var output := Message.new()
	if not json.data is Dictionary: return output
	output.time_stamp = DateTime.now()
	
	if json.data.has("is_encryted"):
		output.is_encryted = json.data["is_encryted"]
	if json.data.has("data"):
		output.data = json.data["data"]
	if json.data.has("origin_pubkey"):
		output.origin_pubkey = Marshalls.base64_to_variant(json.data["origin_pubkey"],true)
	if json.data.has("origin_ip"):
		output.origin_ip = json.data["origin_ip"]
	if json.data.has("origin_username"):
		output.origin_username = json.data["origin_username"]
	if json.data.has("is_system_message"):
		output.is_system_message = json.data["is_system_message"]
	if json.data.has("time_stamp"):
		output.time_stamp = DateTime.new()
		for key in json.data["time_stamp"]:
			output.time_stamp.set(key,json.data["time_stamp"][key])
	if json.data.has("command"):
		output.command = json.data["command"]
	return output
	
static func make_text(new_message: String) -> Message:
	var output := Message.new()
	output.data = new_message
	return output
	
static func make_data(new_message) -> Message:
	var output := Message.new()
	output.data = new_message
	return output

static func make_system(new_command:String, new_data = null) -> Message:
	var output := Message.new()
	var pic: Texture2D
	for profile in GlobalState.usingDB.get_profiles():
		if GlobalState.myIP == profile["myIP"]:
			pic = profile["profile_pic"]
	output.data = Marshalls.variant_to_base64({"data":new_data,"pic":pic},true)
	output.is_system_message = true
	output.command = new_command
	return output
