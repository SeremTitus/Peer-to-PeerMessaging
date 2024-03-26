@tool
extends EditorScript

func _run():
	if test_p2pmessaging() != OK:
		assert(true, "Error with P2PManager")
	if test_database() != OK:
		assert(true, "Error with dbHandler")
	
func test_p2pmessaging() -> Error:
	var p2p = P2PManager.new()
	var ip = GlobalState.generate_myIP()[0]
	var message = Message.make_text("hello world")
	return p2p.send_message(ip,message)

func test_database() -> Error:
	var db = dbHandler.new()
	var ip = GlobalState.generate_myIP()[0]
	var message = Message.make_text("hello world")
	return db.save_message(message,ip)
