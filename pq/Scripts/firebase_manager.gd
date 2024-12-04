extends Node

func saveHighScore(level:String,current_score:int) -> void:
	# Variables to use
	var user_id = str(UserPreferences.get_auth_localid())  # Get the authenticated user ID as string
	
	var collection: FirestoreCollection = Firebase.Firestore.collection("Users")  # Reference to Firestore 'Users' collection
	
	# Fetch the user's document
	var task = await collection.get_doc(user_id)
	
	# Check if the document exists
	if task.document:
		var document = task.document
		
		# Check if the level score exists in the document, otherwise set it to 0
		var saved_score = 0
		if document.has(level):
			var lastScore = int(document.get(level)["integerValue"]) 
			print(lastScore)
			saved_score = int(lastScore)
		# Compare the current score with the saved score
		if current_score >= saved_score:
			# Update the score in Firestore
			var document2 = task
			document2.add_or_update_field(level, current_score)
			var new_document_update = await collection.update(document2) 
			 
		else:
			print("Current score is less than saved score, no update needed.")
	else:
		print("No document found for user ID: ", user_id)

func unlockLevel() -> Array:
	# Variables to use
	var user_id = str(UserPreferences.get_auth_localid())  # Get the authenticated user ID as string
	var collection: FirestoreCollection = Firebase.Firestore.collection("Users")  # Reference to Firestore 'Users' collection
	# Fetch the user's document
	var task = await collection.get_doc(user_id)
	
	# Check if the document exists
	if task.document:
		var document = task.document
		
		# Initialize an empty array to store unlocked levels
		var unlocked_levels = []
		
		# Check for specific levels and append them if they exist
		if document.has("level1"):
			unlocked_levels.append("level1")
		if document.has("level2"):
			unlocked_levels.append("level2")
		if document.has("level3"):
			unlocked_levels.append("level3")
		# Add checks for more levels as needed...
		
		print("Unlocked levels: ", unlocked_levels)
		return unlocked_levels
	else:
		print("No document found for user ID: ", user_id)
		return []

# Initialize dictionaries for each level
var level1CorrectDict = {}
var level2CorrectDict = {}
var level3CorrectDict = {}

var level1ProblemDict = {}
var level2ProblemDict = {}
var level3ProblemDict = {}

# Function to fetch all questions and categorize them by level
func getQuestionAccordingToLevel() -> void:
	if not level1CorrectDict.is_empty():
		return
	
	var db = Firebase.Firestore
	var query: FirestoreQuery = FirestoreQuery.new().from("questions")
	var query_results = await Firebase.Firestore.query(query)
	
	print("GETTING QUESTIONS")
	
	# Check if there are any documents returned
	if query_results.size() > 0:
		# Iterate through all the documents (questions)
		for result in query_results:
			var doc_name = result['doc_name']
			var document = result["document"]
			
			# Retrieve question, options, answer, and level fields
			var question = document["question"]["stringValue"]  # 'question' field in Firestore
			var options = []  # Create an empty array to store the options as strings
			
			# Loop through each option to extract stringValue
			for option in document["options"]["arrayValue"]["values"]:
				options.append(option["stringValue"])
			
			var answer = document["answer"]["stringValue"]  # 'answer' field in Firestore
			var level = document["level"]["stringValue"]  # 'level' field in Firestore
			var hint = document["hint"]["stringValue"]
			
			print(hint)
			print("Level fetched: ", level)

			# Categorize questions and answers into the correct level dictionaries
			match level:
				"1":
					level1CorrectDict[question] = answer
					level1ProblemDict[question] = options
				"2":
					level2CorrectDict[question] = answer
					level2ProblemDict[question] = options
				"3":
					level3CorrectDict[question] = answer
					level3ProblemDict[question] = options
				_:
					print("Unrecognized level: ", level)
		
		# Print to confirm the dictionaries are populated correctly
		print("Level 1 Correct Dictionary: ", level1CorrectDict)
		print("Level 1 Problem Dictionary: ", level1ProblemDict)
		print("Level 2 Correct Dictionary: ", level2CorrectDict)
		print("Level 2 Problem Dictionary: ", level2ProblemDict)
		print("Level 3 Correct Dictionary: ", level3CorrectDict)
		print("Level 3 Problem Dictionary: ", level3ProblemDict)
	else:
		print("No questions found in the collection.")
