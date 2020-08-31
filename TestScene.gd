extends Spatial

onready var mGameSaver = $GameSaver

var firstRun = true

func _ready():
	mGameSaver.load(0)
	randomize()
	if firstRun:
		show_start_up_dialog()
		firstRun = false
	
func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		mGameSaver.save(0)

func show_start_up_dialog():
	var Dialogs = load("res://Dialogs.tscn")
	var mDialogs = Dialogs.instance()
	self.add_child(mDialogs)

func save(save_game: Resource):
	save_game.data["TestScene_firstrun"] = self.firstRun

func load(save_game: Resource):
	if "TestScene_firstrun" in save_game.data:
		self.firstRun = save_game.data["TestScene_firstrun"]
