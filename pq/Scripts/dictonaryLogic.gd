extends Node
var curr_scene = ""

func flask_throw(puddle_key, phial_compound):
	var curr_scene = get_tree().current_scene.name
	var problem_dict = {}  # Initialize an empty dictionary
	var correct_dict = {}  # Initialize an empty dictionary
	# Assign the appropriate dictionaries based on the current scene
	if curr_scene == "level1":
		problem_dict = FirebaseManager.level1ProblemDict
		correct_dict = FirebaseManager.level1CorrectDict
	elif curr_scene == "level2":
		problem_dict = FirebaseManager.level2ProblemDict
		correct_dict = FirebaseManager.level2CorrectDict
	elif curr_scene == "level3":
		problem_dict = FirebaseManager.level3ProblemDict
		correct_dict = FirebaseManager.level3CorrectDict
	else:
		print("Unknown level")
		return
	
	if phial_compound == correct_dict[puddle_key]:
		get_parent().correct()
		# update buttons and puddle
	else:
		get_parent().incorrect()
		shuffle_and_update(puddle_key)

func shuffle_and_update(puddle_key):
	var curr_scene = get_tree().current_scene.name
	var problem_dict = {}  # Initialize an empty dictionary
	# Assign the appropriate dictionaries based on the current scene
	if curr_scene == "level1":
		problem_dict = FirebaseManager.level1ProblemDict
	elif curr_scene == "level2":
		problem_dict = FirebaseManager.level2ProblemDict
	elif curr_scene == "level3":
		problem_dict = FirebaseManager.level3ProblemDict
	else:
		print("Unknown level")
		return
	
	var randomList = problem_dict[puddle_key]
	randomList.shuffle()
	get_parent().button_options = randomList
	get_parent().call("updateText")


func startGameText():
	var curr_scene = get_tree().current_scene.name
	var problem_dict = {}  # Initialize an empty dictionary
	var correct_dict = {}  # Initialize an empty dictionary
	
	# Assign the appropriate dictionaries based on the current scene
	if curr_scene == "level1":
		problem_dict = FirebaseManager.level1ProblemDict
		correct_dict = FirebaseManager.level1CorrectDict
	elif curr_scene == "level2":
		problem_dict = FirebaseManager.level2ProblemDict
		correct_dict = FirebaseManager.level2CorrectDict
	elif curr_scene == "level3":
		problem_dict = FirebaseManager.level3ProblemDict
		correct_dict = FirebaseManager.level3CorrectDict
	else:
		print("Unknown level")
		return
	
	# Proceed with selecting a random problem and options
	var problem_options = correct_dict.keys()
	var randomIndex = randi() % problem_options.size()
	var randomKey = problem_options[randomIndex]
	problem_options.remove_at(randomIndex)
	var randomList = problem_dict[randomKey]
	
	# Set the problem and options in the parent node and call the update method
	get_parent().puddle = randomKey
	randomList.shuffle()
	get_parent().button_options = randomList
	get_parent().call("updateText")


#func startGameText():
	##curr_scene = get_tree().current_scene.name
	##if(curr_scene != "level1"):
		#var problem_dict = FirebaseManager.level1ProblemDict
		#var correct_dict = FirebaseManager.level1CorrectDict
		#var problem_options = correct_dict.keys()
		#var randomIndex = randi() % problem_options.size()
		#var randomKey = problem_options[randomIndex]
		#problem_options.remove_at(randomIndex)
		#var randomList = problem_dict[randomKey]
		#get_parent().puddle = randomKey
		#randomList.shuffle()
		#get_parent().button_options = randomList
		#get_parent().call("updateText")
