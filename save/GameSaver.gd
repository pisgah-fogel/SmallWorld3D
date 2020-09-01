# Saves and loads savegame files
# Each node is responsible for finding itself in the mSaveGame
# dict so saves don't rely on the nodes' path or their source file
extends Node

const SaveGame = preload('res://save/SaveGame.gd')
var SAVE_FOLDER: String = "user://save"
var SAVE_NAME_TEMPLATE: String = "save_%03d.tres"
var mSaveGame = null

func loopSaveNodes(node):
    for N in node.get_children():
        if N.get_child_count() > 0:
            loopSaveNodes(N)
        if N.is_in_group("save"):
            N.save(mSaveGame)
            print("save ["+N.get_name()+"]")
func loopLoadNodes(node):
    for N in node.get_children():
        if N.get_child_count() > 0:
            loopLoadNodes(N)
        if N.is_in_group("save"):
            N.load(mSaveGame)
            print("load ["+N.get_name()+"]")

func appendToSave(parent_node):
	if mSaveGame == null:
		mSaveGame = SaveGame.new()
		print("appendToSave(): No game save: let's create one")
	loopSaveNodes(parent_node)

func restoreDatas(parent_node):
	if mSaveGame == null:
		print("restoreDatas(): Error, cannot restore datas")
		return
	loopLoadNodes(parent_node)

func save(id: int):
	# Passes a SaveGame resource to all nodes to save data from
	# and writes it to the disk
	if mSaveGame == null:
		mSaveGame = SaveGame.new()
		print("No game save: let's create one")
	mSaveGame.game_version = ProjectSettings.get_setting("application/config/version")
	for node in get_tree().get_nodes_in_group('save'):
		node.save(mSaveGame)

	var directory: Directory = Directory.new()
	if not directory.dir_exists(SAVE_FOLDER):
		directory.make_dir_recursive(SAVE_FOLDER)

	var save_path = SAVE_FOLDER.plus_file(SAVE_NAME_TEMPLATE % id)
	var error: int = ResourceSaver.save(save_path, mSaveGame)
	if error != OK:
		print('There was an issue writing the save %s to %s' % [id, save_path])


func load(id: int):
	# Reads a saved game from the disk and delegates loading
	# to the individual nodes to load
	var save_file_path: String = SAVE_FOLDER.plus_file(SAVE_NAME_TEMPLATE % id)
	var file: File = File.new()
	if not file.file_exists(save_file_path):
		print("Save file %s doesn't exist" % save_file_path)
		return
	
	mSaveGame = load(save_file_path)

	for node in get_tree().get_nodes_in_group('save'):
		node.load(mSaveGame)
