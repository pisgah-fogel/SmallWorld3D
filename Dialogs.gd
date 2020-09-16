extends CanvasLayer

onready var mControl = $Control
onready var mText = $Control/Text

var is_reading = false
var current_index = 0

var allChoices = []

var selection = 0

export(int) var choice_x = 870
export(int) var choice_y = -200
export(int) var choice_h = 110

const Choice = preload("res://Choice.tscn")

var variables = {}
var mScript =[
			{
				"text":"Developpeur:\nVous ne devriez pas voir ce message désolé..."
			}
		]

func update_placing():
	offset.y = mControl.get_viewport_rect().size.y-600
	offset.x = mControl.get_viewport_rect().size.x/2-500

var mCallbacks = {}

func registerCallback(callback, key):
	mCallbacks[key] = callback

func stop_reading():
	clear_choices()
	is_reading = false
	current_index = 0
	mControl.visible = false
	get_tree().get_root().get_node("TestScene/GameSaver").appendToSave(self)
	self.queue_free()

func update_text():
	clear_choices()
	selection = -1
	if is_reading:
		mText.text = mScript[current_index]["text"]
		if "options" in mScript[current_index]:
			var i = 0
			for option in mScript[current_index]["options"]:
				var mChoise = Choice.instance()
				mChoise.global_position = Vector2(choice_x, choice_y+i*choice_h)
				i += 1
				mControl.add_child(mChoise)
				mChoise.setText(option["text"])
				mChoise.setActive(false)
				allChoices.append(mChoise)
			# Activate the first choice
			if allChoices.size() > 0:
				selection = 0
				allChoices[0].setActive(true)

func clear_choices():
	for choice in allChoices:
		choice.queue_free()
	allChoices.clear()
	selection = -1

func next_text():
	if is_reading:
		current_index += 1
		readScript()
		

func readScript():
	while true:
		if current_index < mScript.size() and "check" in mScript[current_index]:
			var check_passed = true
			for v in mScript[current_index]["check"]:
				if v in variables and variables[v] == mScript[current_index]["check"][v]:
					pass
				elif mScript[current_index]["check"][v] is bool and mScript[current_index]["check"][v] == false and not v in variables:
					pass
				else:
					check_passed = false
					break
			if check_passed:
				break # Stop looping over all messages and print this one
			else:
				pass
		else:
			break; # Stop looping over all messages and print this one or just stop
		current_index += 1
	
	if current_index < mScript.size():
		update_text()
	else:
		stop_reading()

var apparition: bool = false
func _ready():
	var _a_ = get_tree().get_root().connect("size_changed", self, "_size_changed")
	get_tree().get_root().get_node("TestScene/GameSaver").restoreDatas(self)
	apparition = true
	mControl.modulate.a = 0.0

func _popup():
	update_placing()
	if mScript.size() > 0:
		current_index = 0
		is_reading = true
		readScript()
	else:
		stop_reading()

func _size_changed():
	update_placing()

func update_selection():
	for choice in allChoices:
		choice.setActive(false)
	if allChoices.size() > selection and selection >= 0:
		allChoices[selection].setActive(true)

func setVariables(choice):
	if "clear" in choice:
		for v in choice["clear"]:
			if v in variables:
				variables.erase(v)
	if "set" in choice:
		for v in choice["set"]:
			variables[v] = choice["set"][v]
	if "callback" in choice:
		if choice["callback"] in mCallbacks:
			mCallbacks[choice["callback"]].call_func()
		else:
			print("Error: Dialogs.gd: No callback ", choice["callback"], " found.")

func _process(delta):
	if apparition:
		if mControl.modulate.a < 0.9:
			mControl.modulate.a += delta*1.0
		else:
			mControl.modulate.a = 1.0
			apparition = false

var ignoreInputs = false
func _input(event):
	if ignoreInputs or not is_reading:
		return
	elif event.is_action_pressed("ui_action"):
		setVariables(mScript[current_index])
		if current_index >= 0 and mScript.size() > current_index and "options" in mScript[current_index] and selection >= 0 and selection < mScript[current_index]["options"].size():
			setVariables(mScript[current_index]["options"][selection])
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

func save(save_game: Resource):
	var save_name = get_parent().filename + "_DialogsVars"
	save_game.data[save_name] = variables

func load(save_game: Resource):
	var save_name = get_parent().filename + "_DialogsVars"
	if save_name in save_game.data:
		variables = save_game.data[save_name]
