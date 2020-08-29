extends StaticBody

onready var mAnimationPlayer = $Chest/AnimationPlayer

enum State {CLOSED, OPEN}
var mState = State.CLOSED

func _on_Area_body_entered(body):
	print("Openning Chest")
	match mState:
		State.CLOSED:
			mAnimationPlayer.play("Open")
			mState = State.OPEN
		State.OPEN:
			mAnimationPlayer.play("Close")
			mState = State.CLOSED
