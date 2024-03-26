class_name Message extends RefCounted

var origin_ip: String = GlobalState.myIP 
var origin_username: String
var time_stamp: DateTime = DateTime.now()
var data

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
		"is_system_message": is_system_message,
		"data": data,
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

static func from_json(json:JSON) -> Message:
	var output := Message.new()
	output.time_stamp = DateTime.now()
	output.data = json.data["data"]
	output.origin_ip = json.data["origin_ip"]
	output.origin_username = json.data["origin_username"]
	output.is_system_message = json.data["is_system_message"]
	output.time_stamp = DateTime.new()
	for key in json.data["time_stamp"]:
		output.time_stamp.set(key,json.data["time_stamp"][key])
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
