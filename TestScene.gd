extends Spatial

onready var mGameSaver = $GameSaver
export var default_scene = "res://TestIsland.tscn"
onready var mScreenShader = $SceneShader/ScreenShader

var firstRun = true
var mScene = null

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
	if mScene:
		print("Scene: ", mScene)
		print("have filename: ", mScene.filename)
		save_game.data["Scene"] = mScene.filename
	else:
		print("Error: Cannot find saving default one")
		save_game.data["Scene"] = default_scene

func load(save_game: Resource):
	if "TestScene_firstrun" in save_game.data:
		self.firstRun = save_game.data["TestScene_firstrun"]

	if "Scene" in save_game.data:
		print("Loading ", save_game.data["Scene"])
		loadScene(save_game.data["Scene"], false)
	else:
		loadOnlyDefaultScene(false)

func freeScene():
	if mScene:
		mGameSaver.appendToSave(mScene)
		mScene.queue_free()
		mScene= null

func loadScene(strpath, dyn = true):
	freeScene()
	var error = false
	var obj = load(strpath)
	if not obj:
		print("Cannot load path: ", strpath)
		error = true
	else:
		mScene = obj.instance()
		if not mScene:
			error = true
		else:
			add_child(mScene)
			mGameSaver.restoreDatas(mScene)
			if dyn and mScene.has_method("_dynamic_scene_load"):
				mScene._dynamic_scene_load()
	if error:
		print("Error occured, loading default scene")
		loadOnlyDefaultScene(dyn)

func loadOnlyDefaultScene(dyn = true):
	mScene = load(default_scene).instance()
	add_child(mScene)
	mGameSaver.restoreDatas(mScene)
	if dyn and mScene.has_method("_dynamic_scene_load"):
		mScene._dynamic_scene_load()

var mScreenShaderFilename = ""
func enableScreenShader(shaderName):
	if shaderName == null:
		mScreenShader.visible = false
		if mScreenShader.material and mScreenShader.material.shader:
			# Shader is a reference ? no need to free it (TODO)
			mScreenShader.material.shader = null
		mScreenShaderFilename = ""
	else:
		mScreenShader.visible = true
		# mScreenShader.material is a ShaderMaterial
		mScreenShader.material.shader = load(shaderName)
		mScreenShaderFilename = shaderName

func isShaderActive():
	return mScreenShader.visible

func getActiveShaderFilename() -> String:
	return mScreenShaderFilename
