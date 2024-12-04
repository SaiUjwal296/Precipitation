extends Control

# Called when the node enters the scene tree for the first time.
func _ready():

	# Connect Firebase signals
	Firebase.Auth.login_succeeded.connect(on_login_succeeded)
	Firebase.Auth.signup_succeeded.connect(on_signup_succeeded)
	Firebase.Auth.login_failed.connect(on_login_failed)
	Firebase.Auth.signup_failed.connect(on_signup_failed)
	
	if Firebase.Auth.check_auth_file():
		%StateLabel.text = "Logged in"
		get_tree().change_scene_to_file("res://pq/Menu/main_menu.tscn")

	# Hide first name and last name by default (only for sign-up)
	%FirstNameEdit.hide()
	%LastNameEdit.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Login button pressed
func _on_login_button_pressed():
	# Hide the first and last name fields during login
	%FirstNameEdit.hide()
	%LastNameEdit.hide()

	var email = %EmailLineEdit.text.strip_edges()
	var password = %PasswordLineEdit.text.strip_edges()

	# Check if email or password is empty
	if email == "" or password == "":
		%StateLabel.text = "Email and password cannot be empty."
		return

	# Proceed with login if inputs are valid
	Firebase.Auth.login_with_email_and_password(email.to_lower(), password)
	%StateLabel.text = "Logging in"

# Sign-up button pressed
func _on_signup_button_pressed():
	# Show first name and last name fields when signing up
	%FirstNameEdit.show()
	%LastNameEdit.show()

	var email = %EmailLineEdit.text.strip_edges()
	var password = %PasswordLineEdit.text.strip_edges()
	var first_name = %FirstNameEdit.text.strip_edges()
	var last_name = %LastNameEdit.text.strip_edges()

	# Check if the first name or last name is empty
	if first_name == "" or last_name == "":
		%StateLabel.text = "Please enter both first name and last name."
		return

	# Check if email or password is empty
	if email == "" or password == "":
		%StateLabel.text = "Email and password cannot be empty."
		return
	
	Firebase.Auth.signup_with_email_and_password(email.to_lower(), password)
	%StateLabel.text = "Signing up"

# Sign-up success
func on_signup_succeeded(auth):
	print(auth)
	%StateLabel.text = "Sign up success!"
	Firebase.Auth.save_auth(auth)
	
	var email = %EmailLineEdit.text.strip_edges().to_lower()
	var first_name = %FirstNameEdit.text.strip_edges()
	var last_name = %LastNameEdit.text.strip_edges()
	UserPreferences.save_auth_localid(auth.localid) 
	# Call the method to save the user to Firestore
	save_user_to_firestore(auth, first_name, last_name, email)

	get_tree().change_scene_to_file("res://pq/Menu/main_menu.tscn")

# Save user to Firestore
func save_user_to_firestore(auth, first_name: String, last_name: String, email: String) -> void:
	# Create a Firestore reference
	 
	var collection: FirestoreCollection = Firebase.Firestore.collection("Users")
	var data: Dictionary = {
		"first_name": first_name,
		"last_name": last_name,
		"email": email
	}

	var task: FirestoreDocument = await collection.add(auth.localid, data)
	collection.add(auth.localid, data)

# Login success
func on_login_succeeded(auth):
	print(auth)
	%StateLabel.text = "Login success!"
	Firebase.Auth.save_auth(auth)
	UserPreferences.save_auth_localid(auth.localid) 
	get_tree().change_scene_to_file("res://pq/Menu/main_menu.tscn")

# Login failed
func on_login_failed(error_code, message):
	print(error_code)
	print(message)
	%StateLabel.text = "Login failed. Error: %s" % message

# Sign-up failed
func on_signup_failed(error_code, message):
	print(error_code)
	print(message)
	%StateLabel.text = "Sign up failed. Error: %s" % message
