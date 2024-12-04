extends Node

var music_playing = true
var background_music: AudioStreamPlayer2D
var masterVolume = 1
var musicVolume = 1
var sfxVolume = 1
var curr_scene = ""

@onready var button_order = ["mapMenu/map/map-level1", "mapMenu/map/map-level2", "mapMenu/map/map-level3"]

# Called when the node enters the scene tree for the first time
func _ready():
	background_music = $"background-music"
	background_music.play()
	update_level_access()
	congrats()
	print(UserPreferences.get_auth_localid())
	print(await FirebaseManager.unlockLevel())
	#FirebaseManager.getQuestionAccordingToLevel("level1")

func _process(delta):
	$background.scroll_offset.x -= 60 * delta

# --------------------------------------------------------------
# Main Menu code
# --------------------------------------------------------------

# Start Button - Go to the Map and create the table
func _on_mainstart_btn_pressed():
	if FirebaseManager.level1CorrectDict.is_empty():
		return
	$"sound-effect".play()
	$mapMenu.visible = true
	$mainMenu.visible = false
	$descMenu.visible = false
	$insrMenu.visible = false
	$logoutBtn.visible = false
	update_level_access()

func _on_mainoption_btn_pressed():
	$"sound-effect".play()
	$mapMenu.visible = false
	$mainMenu.visible = false
	$descMenu.visible = false
	$insrMenu.visible = false
	$logoutBtn.visible = false

# Description Button
func _on_maindesc_btn_pressed():
	$"sound-effect".play()
	$mapMenu.visible = false
	$mainMenu.visible = false
	$descMenu.visible = true
	$insrMenu.visible = false
	$logoutBtn.visible = false

func _on_maininsr_btn_pressed():
	$"sound-effect".play()
	$mapMenu.visible = false
	$mainMenu.visible = false
	$descMenu.visible = false
	$insrMenu.visible = true
	$logoutBtn.visible = false

func _complete_game():
	$"sound-effect".play()
	$mapMenu.visible = false
	$mainMenu.visible = false
	$descMenu.visible = true
	$"descMenu/desc/desc-title".hide()
	$"descMenu/desc/desc-content".hide()

# --------------------------------------------------------------
# Unlock levels and check game progress
# --------------------------------------------------------------

func update_level_access():
	
	await FirebaseManager.getQuestionAccordingToLevel()
	
	# Loop through the buttons and disable all
	for x in range(button_order.size()):
			get_node(button_order[x]).set_disabled(true)  # Lock the level button

# Get the unlocked levels from the Firestore document
	var unlocked_levels = await FirebaseManager.unlockLevel()  # Call the unlockLevel function
	get_node(button_order[0]).set_disabled(false)  # Unlock the level button
	
	if unlocked_levels.has("level1"):
			get_node(button_order[0]).set_disabled(false)  # Unlock the level button
			get_node(button_order[1]).set_disabled(false)  # Unlock the level button
		
	if unlocked_levels.has("level2"):
			get_node(button_order[0]).set_disabled(false)  # Unlock the level button
			get_node(button_order[1]).set_disabled(false)  # Unlock the level button
			get_node(button_order[2]).set_disabled(false)  # Unlock the level button

#func update_level_access():
	## Unlock all levels regardless of progress
	#for x in range(button_order.size()):
		#get_node(button_order[x]).set_disabled(false)  # Unlock all level buttons
		#get_node(button_order[x]).add_theme_color_override("font_color", "Green")  # Show the levels as accessible


func congrats():
	# Check if all levels are completed
	for lvl in Global.pq_progress:
		if !lvl:
			return
	$finishMenu/confetti.play()
	$finishMenu/confetti2.play()
	$finishMenu/dolphin.play()
	$finishMenu.show()

# --------------------------------------------------------------
# Options code
# --------------------------------------------------------------

func _on_optionback_btn_pressed():
	$"sound-effect".play()
	$mapMenu.visible = false
	$mainMenu.visible = true
	$descMenu.visible = false
	$logoutBtn.visible = false
	$insrMenu.visible = false

# Volume setup
func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

# Master slider
func _on_master_value_changed(value):
	volume(0, value)
	masterVolume = value

# Music slider
func _on_music_value_changed(value):
	volume(1, value)
	musicVolume = value

# Sound fx slider
func _on_sfx_value_changed(value):
	volume(2, value)
	sfxVolume = value

# Mute toggles
func _on_optionmaster_box_toggled(toggled_on):
	if toggled_on:
		volume(0, 0)
	else:
		volume(0, masterVolume)

func _on_optionmusic_box_toggled(toggled_on):
	if toggled_on:
		volume(1, 0)
	else:
		volume(1, musicVolume)

func _on_optionsfx_box_toggled(toggled_on):
	if toggled_on:
		volume(2, 0)
	else:
		volume(2, sfxVolume)

# --------------------------------------------------------------
# Map code
# --------------------------------------------------------------

# Switch scene when a level button is pressed
func _on_mapbtn_pressed(level):
	$"sound-effect".play()
	$mapMenu.visible = false
	$mainMenu.visible = false
	$descMenu.visible = false
	get_tree().change_scene_to_file("res://pq/" + level +".tscn")

# Back Button: Go back to the main menu
func _on_mapback_btn_pressed():
	$"sound-effect".play()
	$mapMenu.visible = false
	$mainMenu.visible = true
	$descMenu.visible = false
	$insrMenu.visible = false
	$logoutBtn.visible = true


# --------------------------------------------------------------
# Database Update Functionality
# --------------------------------------------------------------

# Update player's current level in the database


func _on_logout_btn_pressed():
	Firebase.Auth.logout()
	get_tree().change_scene_to_file("res://pq/Authentication.tscn")
