class_name dbHandler extends RefCounted


var db: SQLite = SQLite.new()

func _init():
	db.path = "user://store.db"
	db.verbosity_level = SQLite.VERY_VERBOSE
	db.open_db()


func save_message(message:Message, myIP:String = GlobalState.myIP) -> Error:
	if myIP.is_empty() or message.origin_ip.is_empty() or message == null or message.is_system_message: return FAILED
	var table_name: String = str("m" + myIP + message.origin_ip).replace(".","")
	var table_dict: Dictionary = {
		"id" : {"data_type":"int", "auto_increment": true},
		"origin_ip": {"data_type":"text"},
		"data": {"data_type":"blob"},
		"command": {"data_type":"text"},
		"year" : {"data_type":"int"},
		"month" : {"data_type":"int"},
		"weekday" : {"data_type":"int"},
		"day" : {"data_type":"int"},
		"hour" : {"data_type":"int"},
		"minute" : {"data_type":"int"},
		"second" : {"data_type":"int"},
		"read_status" :{"data_type":"int","default":0}
		}
	db.create_table(table_name, table_dict)
	var data_dict: Dictionary = {
		"origin_ip": message.origin_ip,
		"data": encode_to_blob(message.data),
		"command": message.command,
		"year" : message.time_stamp.year,
		"month" : message.time_stamp.month,
		"weekday" : message.time_stamp.weekday,
		"day" : message.time_stamp.day,
		"hour" : message.time_stamp.hour,
		"minute" : message.time_stamp.minute,
		"second" : message.time_stamp.second
		}
	if db.insert_row(table_name, data_dict):
		return OK
	return FAILED

func get_message(contactIP: String,myIP:String = GlobalState.myIP) -> Array[Message]:
	if contactIP.is_empty() or myIP.is_empty(): return []
	var table_name: String = str("m" + myIP + contactIP).replace(".","")
	var selected_array = db.select_rows(table_name,"", ["*"])
	var output: Array[Message] = []
	for record in selected_array:
		var message: Message = Message.new()
		message.origin_ip = record["origin_ip"]
		message.data = decode_to_object(record["data"])
		message.time_stamp = DateTime.new()
		message.time_stamp.year = record["year"]
		message.time_stamp.month = record["month"]
		message.time_stamp.weekday = record["weekday"]
		message.time_stamp.day = record["day"]
		message.time_stamp.hour = record["hour"]
		message.time_stamp.minute = record["minute"]
		message.time_stamp.second= record["second"]
		output.append({"message":message,"id":record["id"],"read_status":record["read_status"]})
	return output

func read_messages(contactIP: String,myIP:String = GlobalState.myIP) -> Error:
	if myIP.is_empty() or contactIP.is_empty(): return FAILED
	var table_name: String = str("m" + myIP + contactIP).replace(".","")
	var data_dict: Dictionary = Dictionary()
	var query_conditions:String = "read_status = 0"
	data_dict["read_status"] = 1
	if db.update_rows(table_name,query_conditions , data_dict):
		return OK
	return FAILED
	
func  add_profile(myIP:String = GlobalState.myIP,username:String = "",profile_pic:Texture2D = null) -> Error:
	if myIP.is_empty(): return FAILED
	var table_name: String = "me"
	var table_dict: Dictionary = Dictionary()
	table_dict["myIP"] = {"data_type":"text", "primary_key": true, "not_null": true}
	table_dict["username"] = {"data_type":"text"}
	table_dict["profile_pic"] = {"data_type": "blob"}
	db.create_table(table_name, table_dict)
	
	var data_dict: Dictionary = Dictionary()
	data_dict["myIP"] = myIP
	data_dict["username"] = username
	if profile_pic != null:
		data_dict["profile_pic"] = encode_to_blob(profile_pic)
	if db.insert_row(table_name, data_dict):
		return OK
	return FAILED

func  get_profiles() -> Array:
	var table_name: String = "me"
	var selected_array = db.select_rows(table_name,"", ["*"])
	var output: Array = []
	for record in selected_array:
		var profile: Dictionary = {}
		profile["myIP"] = record["myIP"]
		profile["username"] = record["username"]
		if record["profile_pic"] != null and not record["profile_pic"].is_empty():
			profile["profile_pic"] = decode_to_object(record["profile_pic"])
		else:
			profile["profile_pic"] = null
		output.append(profile)
	return output

func update_profile(myIP:String = GlobalState.myIP ,username:String = "",profile_pic:Texture2D = null) -> Error:
	if myIP.is_empty(): return FAILED
	var table_name: String = "me"
	var data_dict: Dictionary = Dictionary()
	var query_conditions:String = "myIP = '" + myIP +"'"
	data_dict["username"] = username
	if profile_pic != null:
		data_dict["profile_pic"] = encode_to_blob(profile_pic)
	if db.update_rows(table_name,query_conditions , data_dict):
		return OK
	return FAILED

func  add_contact(contactIP:String,username:String = "",profile_pic:Texture2D = null,myIP:String = GlobalState.myIP ) -> Error:
	if contactIP.is_empty() or myIP.is_empty(): return FAILED
	var table_name: String = str("contact"+myIP).replace(".","")
	var table_dict: Dictionary = Dictionary()
	table_dict["contactIP"] = {"data_type":"text", "primary_key": true, "not_null": true}
	table_dict["username"] = {"data_type":"text"}
	table_dict["profile_pic"] = {"data_type": "blob"}
	db.create_table(table_name, table_dict)
	
	var data_dict: Dictionary = Dictionary()
	data_dict["contactIP"] = contactIP
	data_dict["username"] = username
	if profile_pic != null:
		data_dict["profile_pic"] = encode_to_blob(profile_pic)
	if db.insert_row(table_name, data_dict):
		return OK
	return FAILED

func  get_contacts(myIP:String = GlobalState.myIP) -> Array:
	if myIP.is_empty(): return []
	var table_name: String = str("contact"+myIP).replace(".","")
	var selected_array = db.select_rows(table_name,"", ["*"])
	var output: Array = []
	for record in selected_array:
		var profile: Dictionary = {}
		profile["contactIP"] = record["contactIP"]
		profile["username"] = record["username"]
		if record["profile_pic"] != null and not record["profile_pic"].is_empty():
			profile["profile_pic"] = decode_to_object(record["profile_pic"])
		else:
			profile["profile_pic"] = null
		output.append(profile)
	return output

func update_contact(contactIP:String,username:String = "",profile_pic:Texture2D = null,myIP:String = GlobalState.myIP ) -> Error:
	if contactIP.is_empty() or myIP.is_empty() : return FAILED
	var table_name: String =str("contact"+myIP).replace(".","")
	var data_dict: Dictionary = Dictionary()
	var query_conditions:String = "contactIP = '" + contactIP+"'"
	if not username.is_empty():
		data_dict["username"] = username
	if profile_pic != null:
		data_dict["profile_pic"] = encode_to_blob(profile_pic)
	if db.update_rows(table_name,query_conditions , data_dict):
		return OK
	return FAILED

func delete_contact(contactIP:String,myIP:String = GlobalState.myIP) -> Error:
	if contactIP.is_empty() or myIP.is_empty() : return FAILED
	var table_name: String =str("contact"+myIP).replace(".","")
	var query_conditions:String = " contactIP = '" + contactIP+"'"
	if db.delete_rows(table_name,query_conditions):
		return OK
	return FAILED
	
func encode_to_blob(obj:Variant) -> PackedByteArray:
	var output:PackedByteArray = Marshalls.base64_to_raw(Marshalls.variant_to_base64(obj,true))
	return output

func  decode_to_object(blob:PackedByteArray) -> Variant:
	var obj:Variant = Marshalls.base64_to_variant(Marshalls.raw_to_base64(blob),true)
	return obj

func _notification(what:int) -> void:
	if what == NOTIFICATION_PREDELETE:
		db.close_db()
