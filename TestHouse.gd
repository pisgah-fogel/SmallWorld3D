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
	# Remove the current level
	self.queue_free()
	# Add the next level
	var next_level_resource = load("res://TestIsland.tscn")
	var next_level = next_level_resource.instance()
	mRoot.add_child(next_level)

	mCharacter.translation = oldCharacterPosition + mCharacter.translation
	# TODO: use a splash screen to hide the teleportation
	
