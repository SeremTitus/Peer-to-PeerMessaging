class_name e2ee extends RefCounted

static func  generate_key() -> CryptoKey:
	var crypto = Crypto.new()
	return crypto.generate_rsa(4096)

static func encrypt(message:PackedByteArray,key:CryptoKey) -> PackedByteArray:
	if  message.is_empty() or key == null: return message
	var crypto = Crypto.new()
	return crypto.encrypt(key,message)

static func decrypt(message:PackedByteArray,key:CryptoKey) -> PackedByteArray:
	if  message.is_empty() or key == null: return message
	var crypto = Crypto.new()
	return crypto.decrypt(key,message)
	
static func public_key_only(key:CryptoKey) -> CryptoKey:
	if key == null or key.is_public_only() : return key
	var crypto:CryptoKey = CryptoKey.new()
	crypto.load_from_string(key.save_to_string(true),true)
	return crypto
