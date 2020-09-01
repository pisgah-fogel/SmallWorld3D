extends Spatial

var mCharacter = null
var mRoot = null
var oldCharacterPosition = Vector3.ZERO
export var unique_house_id = 1

func _dynamic_scene_load():
	oldCharacterPosition = mCharacter.translation
	mCharacter.translation = Vector3.ZERO

func _ready():
	mRoot = get_tree().get_root()
	mCharacter = mRoot.get_node("TestScene/Character")

func _on_TeleportBack_body_entered(body):
	print("Teleport out of the house")
	var level = get_tree().get_root().get_node("TestScene")
	level.loadScene("res://TestIsland.tscn")
	mCharacter.translation = oldCharacterPosition + mCharacter.translation
	# TODO: use a splash screen to hide the teleportation
	
func save(save_game: Resource):
	save_game.data["testhouse_"+str(unique_house_id)+"_charpos"] = oldCharacterPosition

func load(save_game: Resource):
	if oldCharacterPosition == Vector3.ZERO and "testhouse_"+str(unique_house_id)+"_charpos" in save_game.data:
		oldCharacterPosition = save_game.data["testhouse_"+str(unique_house_id)+"_charpos"]
