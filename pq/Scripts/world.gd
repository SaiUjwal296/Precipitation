extends Node2D

var curr_scene = ""
var puddle_tops = []
var puddles = []
var scrolling = false
var index = 0
var should_move = true
# Called when the node enters the scene tree for the first time.
func _ready():
	curr_scene = get_tree().current_scene.name
	if(curr_scene == "level1" or curr_scene == "level2" or curr_scene == "level3"):
		puddle_tops.append($PuddleTop)
		puddles.append($Puddle)
		puddle_tops.append($PuddleTop2)
		puddles.append($Puddle2)
		puddle_tops.append($PuddleTop3)
		puddles.append($Puddle3)
		puddle_tops.append($PuddleTop4)
		puddles.append($Puddle4)
		puddle_tops.append($PuddleTop5)
		puddles.append($Puddle5)
		puddle_tops.append($PuddleTop6)
		puddles.append($Puddle6)
		puddle_tops.append($PuddleTop7)
		puddles.append($Puddle7)
		puddle_tops.append($PuddleTop8)
		puddles.append($Puddle8)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(scrolling == true):
		$Background.scroll_offset.x -= 60*delta

func flask_throw():
	if (should_move):
		index = get_parent().question_number
	puddle_tops[index].stop()
	puddle_tops[index].play("default")

func move_forward():
	scrolling = true
	var tween : Tween = create_tween()
	var new_pos = Vector2(self.position[0] + -1152, 0)
	tween.tween_property(self, "position", new_pos, 2)
	await tween.finished
	scrolling = false

func success():
	if (should_move):
		index = get_parent().question_number
	puddles[index].stop()
	puddles[index].play("default")
	
func failed():
	if (should_move):
		index = get_parent().question_number
	puddles[index].stop()
	puddles[index].play("incorrect")
	
