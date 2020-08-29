extends Spatial

onready var mGameSaver = $GameSaver

func _ready():
	mGameSaver.load(0)
	randomize()
	
func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		mGameSaver.save(0)
