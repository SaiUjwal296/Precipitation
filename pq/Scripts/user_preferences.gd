extends Node

var auth_localid = ""

func save_auth_localid(localid: String) -> void:
	auth_localid = localid
	# Save auth_localid to a custom config file instead of project.godot
	var config = ConfigFile.new()
	config.set_value("auth", "auth_localid", auth_localid)
	config.save("user://auth_config.cfg")  # Saves to user data directory

func get_auth_localid() -> String:
	# Load the auth_localid from the custom config file
	var config = ConfigFile.new()
	var err = config.load("user://auth_config.cfg")
	if err == OK:
		return config.get_value("auth", "auth_localid", "NA")  # Default is "NA" if not found
	return "NA"
