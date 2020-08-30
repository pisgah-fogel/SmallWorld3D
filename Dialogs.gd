extends CanvasLayer

onready var mControl = $Control
onready var mText = $Control/Text

var is_reading = false
var current = null
var current_index = 0

var allChoices = []

var selection = 0

export(int) var choice_x = 870
export(int) var choice_y = 200
export(int) var choice_h = 110

const Choice = preload("res://Choice.tscn")

var variables = {}
var mScript = [
	{
		"startup": true,
		"msg": [
			{
				"text":"Hello and welcome,\npress 'A' to play with us !"
			},
			{
				"text":"Good job !\nBy the way, How are you ?",
				"question":true,
				"options":[
					{"text":"Good", "set":{"isOk":true}},
					{"text":"Bof...", "set":{"isOk":false}}
					]
			},
			{
				"check":{"isOk":false},
				"text":"So bad...\nBut don't worry, here you can have fun !"
			},
			{
				"check":{"isOk":true},
				"text":"Nice !\nHave fun !"
			}
		]
	}
]

func update_placing():
	offset.y = mControl.get_viewport_rect().size.y-600
	offset.x = mControl.get_viewport_rect().size.x/2-500

func stop_reading():
	clear_choices()
	is_reading = false
	current = null
	current_index = 0
	mControl.visible = false

func update_text():
	selection = -1
	if current and is_reading:
		mText.text = current[current_index]["text"]
		if "options" in current[current_index]:
			var i = 0
			for option in current[current_index]["options"]:
				var mChoise = Choice.instance()
				mChoise.global_position = Vector2(choice_x, choice_y+i*choice_h)
				i += 1
				add_child(mChoise)
				mChoise.setText(option["text"])
				mChoise.setActive(false)
				allChoices.append(mChoise)
			if allChoices.size() > 0:
				selection = 0
				allChoices[0].setActive(true)

func clear_choices():
	for choice in allChoices:
		choice.queue_free()
	allChoices.clear()
	selection = -1

func next_text():
	clear_choices()
	if current and is_reading:
		# if no check: ok
		# if check it need to match variables
		var continue_loop = true
		while continue_loop:
			current_index += 1
			if current_index < current.size() and "check" in current[current_index]:
				for v in current[current_index]["check"]:
					if v in variables and variables[v] == current[current_index]["check"][v]:
						print(v, " match ", variables[v])
						continue_loop = false
			else:
				continue_loop = false
		
		if current_index < current.size():
			update_text()
		else:
			stop_reading()

func _ready():
	get_tree().get_root().connect("size_changed", self, "_size_changed")
	update_placing()
	for item in mScript:
		if item["startup"]:
			is_reading = true
			current = item["msg"]
			current_index = 0
	update_text()

func _size_changed():
	update_placing()

func update_selection():
	for choice in allChoices:
		choice.setActive(false)
	if allChoices.size() > selection and selection >= 0:
		allChoices[selection].setActive(true)

func _userChoosed(choice):
	if "set" in choice:
		for v in choice["set"]:
			variables[v] = choice["set"][v]

func _input(event):
	if not is_reading:
		return
	elif event.is_action_pressed("ui_action"):
		if allChoices.size() > 0 and selection >= 0:
			_userChoosed(current[current_index]["options"][selection])
		next_text()
	elif event.is_action_pressed("ui_up"):
		if selection <= 0:
			selection = allChoices.size()-1
		else:
			selection -= 1
		update_selection()
	elif event.is_action_pressed("ui_down"):
		if selection >= allChoices.size()-1:
			selection = 0
		else:
			selection += 1
		update_selection()
	get_tree().set_input_as_handled()
