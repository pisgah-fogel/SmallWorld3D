extends StaticBody

onready var mAnimationPlayer = $Chest/AnimationPlayer

enum State {CLOSED, OPEN}
var mState = State.CLOSED

export var mObjects = []
export var num_column = 3
export var num_row = 1

var tileStart = Vector2(2, 1)

func _on_Area_body_entered(body):
	print("Openning Chest")
	match mState:
		State.CLOSED:
			mAnimationPlayer.play("Open")
			mState = State.OPEN
		State.OPEN:
			mAnimationPlayer.play("Close")
			mState = State.CLOSED
	body.get_parent().get_parent()._on_chestOpenned(self)

func closeChest():
	match mState:
		State.CLOSED:
			pass
		State.OPEN:
			mAnimationPlayer.play("Close")
			mState = State.CLOSED

func setItem(index:int, object):
	if index < 0:
		return false
	elif index < mObjects.size():
		mObjects[index] = object
		return true
	elif index < num_column*num_row:
		mObjects.append(object)
		return true
	else:
		return false

##################### SAVING RESOURCES ########################

func save(save_game: Resource):
	save_game.data["chest_1_objects"] = mObjects # TODO: generate for each chest

func load(save_game: Resource):
	mObjects = save_game.data["chest_1_objects"]
