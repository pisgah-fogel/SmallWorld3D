extends Spatial

var mCharacter = null
var mRoot = null
var oldCharacterPosition = Vector3.ZERO

func _ready():
	mRoot = get_tree().get_root()
	mCharacter = mRoot.get_node("TestScene/Character")
	oldCharacterPosition = mCharacter.translation
	mCharacter.translation = Vector3.ZERO
	

func _on_TeleportBack_body_entered(body):
	print("Teleport out of the house")
	var level = get_tree().get_root().get_node("TestScene")
	level.loadScene("res://TestIsland.tscn")

	mCharacter.translation = oldCharacterPosition + mCharacter.translation
	# TODO: use a splash screen to hide the teleportation
	
func save(save_game: Resource):
	save_game.data["testhouse_1_charpos"] = oldCharacterPosition

func load(save_game: Resource):
	if "testhouse_1_charpos" in save_game.data:
		oldCharacterPosition = save_game.data["testhouse_1_charpos"]
