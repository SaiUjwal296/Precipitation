extends CanvasLayer

# Variables for tracking the game state
var button_options = ["", "", ""]
var puddle = ""
var curr_scene = ""
var health_var = 3
var questions_correct = 0  # Correctly answered questions
var points = 0              # Current points
var questions_needed = 0     # Questions needed for level completion
var is_help_active = false

# Called when the node enters the scene tree for the first time
func _ready():
	# Set the current scene name
	curr_scene = get_tree().current_scene.name
	# Initialize questions_needed based on the level
	match curr_scene:
		"level1":
			questions_needed = 10
			$HelpButton.hide()
		"level2":
			questions_needed = 8
		"level3":
			questions_needed = 8

	# Start the game and update the UI text elements
	$ScienceScript.startGameText()
	updateText()

# Function to update all text elements based on the game state
func updateText():
	if curr_scene == "level1":
		$Questions.text = puddle
		$Questions.visible = true
		$Puddle.visible = false
		$Flasks/level1options/loption1.text = button_options[0]
		$Flasks/level1options/loption2.text = button_options[1]
		$Flasks/level1options/loption3.text = button_options[2]
		$Flasks/FlaskHolder.hide()
		$HelpButton.hide()
		$HelpButton/chart.hide()
	else:
		$Flasks/FlaskHolder/Option1.text = button_options[0]
		$Flasks/FlaskHolder/Option2.text = button_options[1]
		$Flasks/FlaskHolder/Option3.text = button_options[2]
		$Puddle.text = puddle
		$Puddle.visible = true
		$Questions.visible = false
		$Flasks/level1options.hide()

	$PointsLabel.text = "Points: " + str(points)  # Update points display
	$QNo.text = "QNo : " + str(questions_correct)  # Display current question number


# Triggered when a chemical button is pressed
func _on_chem_button_pressed(button):
	if $PauseButton.button_pressed or is_help_active:
		print("Disabling throw function while hints are being shown")
		return
	else:
		# Hide flasks and trigger the throw
		$Flasks.hide()
		get_tree().call_group("flask_reactions", "flask_throw")
		$ScienceScript.flask_throw(puddle, button_options[button])
		# Display relevant UI elements again
		if curr_scene != "level1":
			$HelpButton.show()
		$PauseButton.show()
		$Health.show()
		$PointsLabel.show()
		$Textbox.hide()

# Function to handle incorrect answers and skip to the next question in level 1
func incorrect():
	await get_tree().create_timer(2).timeout
	$wrong.play()
	get_tree().call_group("flask_reactions", "failed")
	await get_tree().create_timer(2).timeout
	health_var -= 1
	$Health.get_children()[health_var].hide()
	$Textbox.visible = true
	$Textbox/TextboxScript.update_dolphin_textbox("Make sure that you add a soluble ionic compound so that the ions are free to react.")
	$Textbox/TextboxContainer.visible = true
	
	await get_tree().create_timer(5).timeout
	$Textbox.visible = false
	$Textbox/TextboxContainer.visible = false

	# Check for health depletion
	if health_var == 0:
		# Show game-over options
		$Flasks.hide()
		$PauseButton.hide()
		$Puddle.hide()
		$Questions.hide()
		$PointsLabel.hide()
		$Retry.show()
		$ExitButton.show()
		$HelpButton.hide()
		get_tree().change_scene_to_file("res://pq/Level/level_failed.tscn")
	else:
		if curr_scene == "level1":
			# Skip to the next question
			print("Skipping to the next question.")
			$ScienceScript.startGameText()
			if questions_correct < questions_needed:
				questions_correct += 1
			$QNo.text = "QNo : " + str(questions_correct)
			$Flasks.show()
			$HelpButton.hide()
		else:
			$Flasks.show()

# Function to handle correct answers
func correct():
	questions_correct += 1  # Increment the number of correctly answered questions
	points += 5             # Add 5 points for each correct answer
	print("Correct questions: ", questions_correct, "Points: ", points)
	$QNo.text = "QNo : " + str(questions_correct)
	$PointsLabel.text = "Points: " + str(points)
	$correct.play()
	await get_tree().create_timer(2).timeout
	get_tree().call_group("flask_reactions", "success")
	await get_tree().create_timer(3).timeout

	# Check if level is complete
	if questions_correct < questions_needed:
		# Continue to the next question if level is not complete
		$Health.hide()
		self.hide()
		$ScienceScript.startGameText()
		if curr_scene != "level1":
			get_tree().call_group("flask_reactions", "_walk")
			get_tree().call_group("flask_reactions", "move_forward")
			await get_tree().create_timer(2).timeout
			get_tree().call_group("flask_reactions", "_stop")
		get_parent().question_number += 1
		self.show()
		$Health.show()
		$Flasks.show()
	else:
		# If questions_correct exceeds the threshold
		print("Level complete!")
		match curr_scene:
			"level1":
				Global.pq_progress[0] = true
			"level2":
				Global.pq_progress[1] = true
			"level3":
				Global.pq_progress[2] = true
		get_tree().change_scene_to_file("res://pq/Level/level_completed.tscn")
		$Flasks.show()

# Handle pause button toggling
func _on_pause_button_toggled(toggled_on):
	$ExitButton.visible = toggled_on
	$Health.visible = !toggled_on
	$PointsLabel.visible = !toggled_on
	$QNo.visible = !toggled_on
	$Textbox.visible = toggled_on
	$Flasks.visible = !toggled_on
	$HelpButton.visible = !toggled_on
	if curr_scene != "level1":
		$Puddle.visible = !toggled_on
	else:
		$Questions.visible = !toggled_on
		$HelpButton.hide()

# Counter for help button presses
var help_button_press_count = 0

# Handle help button toggling
func _on_help_button_toggled(toggled_on):
	if curr_scene != "level1":
		help_button_press_count += 1
		if help_button_press_count % 2 == 1:
			is_help_active = true
			$HelpButton.visible = true
			$PauseButton.visible = false
			$ExitButton.visible = false
			$Health.visible = false
			$PointsLabel.visible = false
			$QNo.visible = false
			$Textbox.visible = true
			$Textbox/TextboxScript.update_dolphin_textbox(hint_dict[puddle])
			$Textbox/TextboxContainer.visible = true
			$HelpButton/chart.visible = true
		else:
			is_help_active = false
			if curr_scene != "level1":
				$HelpButton.visible = true
			$PauseButton.visible = true
			$ExitButton.visible = false
			$Health.visible = true
			$PointsLabel.visible = true
			$QNo.visible = true
			$Textbox.visible = false
			$Textbox/TextboxContainer.visible = false
			$HelpButton/chart.visible = false
			$HelpButton/chart/SolubilityChart.visible = false
			$HelpButton/chart/SolubilityKey.visible = false

# Handle chart visibility toggle
func _on_chart_pressed(toggled_on):
	is_help_active = toggled_on
	$HelpButton/chart/SolubilityChart.visible = toggled_on
	$HelpButton/chart/SolubilityKey.visible = toggled_on

# Handle exit button press
func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res:///pq/Menu/main_menu.tscn")




##function to show hint for individual flask button pressed
#func show_hints(compound):
	#if (compound == "Hg2(NO3)2"):
		#$Textbox/TextboxScript.update_dolphin_textbox("Hg2(NO3)2")
	#elif (compound == "AgBr"):
		#$Textbox/TextboxScript.update_dolphin_textbox("AgBr")
	#elif (compound ==  "MgCO3"):
		#$Textbox/TextboxScript.update_dolphin_textbox("MgCO3")

var hint_dict = {
	"K⁺  Cl⁻": "You are measuring the chemical oxygen demand of a wastewater sample. Chloride ions interfere with the analysis. Choose a soluble ionic compound to add that will precipitate out the chloride ion.",
	"Na⁺  C₂O₄²⁻": "Oxalate ions are found in food and beverages such as soft drinks. They form kidney stones. Choose the soluble ionic compound that will form a solid with the oxalate ion.",
	"K⁺  F⁻": "Fluoride is naturally found in some water. Too much of it causes skeletal fluorosis. Choose the soluble ionic compound that you can add to remove fluoride from water.",
	"Al³⁺  Cl⁻": "The aluminum ion is toxic to plants. It also precipitates out on fish gills and suffocates them. Choose that soluble ionic compound that you can add to remove aluminum ions from water.",
	"Na⁺  CO₃²⁻": "In water treatment, a protective coating is intentionally formed over iron and lead pipes to reduce iron and lead ions in water. Choose the soluble ionic compound that you could add to water to form a protective coating on pipes with the carbonate ion.",
	"Pb²⁺  NO₂⁻": "Your town has lead ions in its water. Choose the soluble ionic compound that can be added to precipitate the lead ions out of the water.",
	"Ca²⁺  Br⁻": "Your community has hard water caused by calcium and magnesium ions in the water. Hard water causes several issues such as soap scum formation. Choose the soluble ionic compound that you could add to soften the water.",
	#"KNO3": "Your house has its own well. Fertilizer applied nearby has been converted into nitrate through the nitrogen cycles. The concentration of nitrate ion in your well is high, which can lead to adverse health effects. Choose the soluble ionic compound to add to remove the nitrate from your well water.",
	"Fe²⁺  Cl⁻": "You drink well water that contains Fe2+ ions. When the water is exposed to air, Fe2+ is oxidized to Fe3+. Fe3+ then forms a rust-colored precipitate. Choose the soluble ionic compound to add to form this rust colored precipitate.",
	"Na⁺  PO₄³⁻": "Phosphate is used as a fertilizer on farms, lawns, golf courses etc. Some of the phosphate ends up in lakes, contributing to harmful algal blooms. Choose the soluble ionic compound to add to your lake to remove phosphate ions from the water.",
	"K⁺  AsO₄³⁻": "Arsenate is found in minerals and can make its way into groundwater and be carcinogenic. Choose the soluble ionic compound that you can add to your water supply to remove the arsenate ion as a solid.",
	"Cd²⁺  SO₄²⁻": "Cadmium is a toxic heavy metal that can be found in drinking water. Choose the soluble ionic compound that you can add to your water supply to remove cadmium ions.",
	"Cr³⁺  SCN⁻": "Chromium is a toxic heavy metal that can be found in drinking water. Choose the soluble ionic compound that you can add to your water supply to remove chromium ions.",
	#"LiClO4": "The perchlorate ion is used in explosives such as fireworks and in military applications. Due to negative health effects, perchlorate is limited to 10 µg/L in drinking water. Since all perchlorates are soluble, it is difficult to remove. It must be removed with a method other than precipitation.",
	"Ag⁺  NO₃⁻": "You want to measure the concentration of chloride ions in a urine sample as part of a research project. One way to measure the concentration of chloride ion involves turning it into a solid ionic compound. Choose the soluble ionic compound that you can add to form a solid with chloride ions.",
	"K⁺  CrO₄²⁻": "Chromium is a toxic heavy metal that can be found in drinking water. Choose the soluble ionic compound that you can add to your water supply to remove cadmium ions.",
	"Na⁺  PO₄³⁻  OH⁻": "Tooth enamel and bone are ionic compounds. Choose the soluble ionic compound that you could add to form tooth enamel.",
	"Na⁺  AsO₄³⁻ OH⁻": "Clinoclase is a mineral composed of an insoluble ionic compound that forms in nature by precipitation reactions. Choose the soluble ionic compound that you can add to form Clinoclase.",
	"Hg²⁺  Cl⁻": "Mercury is a toxic heavy metal that cycles through the environment. It is found in minerals and is released into the environment through both natural and anthropogenic processes. Mercury (II) is the monatomic ion form. Choose the soluble ionic compound that you can add to remove mercury (II) ions from water.",
	"Hg₂²⁺  NO₃⁻": "Mercury (I) is the polyatomic ion form of mercury. Like mercury (II), it can be removed from water using precipitation reactions. Choose the soluble ionic compound that you can add to remove mercury (I) ions from water."
}

#var tutorial_dict = {
	#"tutorial" : "Welcome to the Ocean Lab tutorial. Press the flask button to throw a phial",
	#"phial": "When this button is pressed, the player throws a phial hoping to form a precipitate in the puddle. Now press the pause button.",
	#"speaker": "Fancy some music? Toggle it on and off with this button",
	#"help": "this button's functionality is under construction",
	#"exit" : "press the exit button if you are ready",
	#"pause" : "Pausing shows a hint! The help button shows a solubility table. (Finding tables online may be needed). You can exit now.",
	#"play" : "press play when you are ready to throw the phial"
#}
