extends CanvasLayer


onready var mColorRect = $ColorRect
onready var mText = $ColorRect/Text
onready var mTimer = $Timer

export (float) var notificationDuration = 3

enum State {IDLE, APPEARS, WAIT, DISAPPEARS}
var mState = State.IDLE

func _ready():
	mColorRect.visible = false
	mState = State.IDLE

func notif(text):
	mTimer.start(notificationDuration)
	mText.text = text
	mColorRect.visible = true
	mColorRect.modulate.a = 0.0
	mState = State.APPEARS

func _process(delta):
	match mState:
		State.APPEARS:
			mColorRect.modulate.a += delta*1.0
			if mColorRect.modulate.a > 0.9:
				mColorRect.modulate.a = 1.0
				mState = State.WAIT
		State.DISAPPEARS:
			mColorRect.modulate.a -= delta*1.0
			if mColorRect.modulate.a < 0.1:
				mColorRect.modulate.a = 0.0
				mState = State.IDLE
				mColorRect.visible = false

func _on_Timer_timeout():
	mColorRect.visible = false
	mState = State.DISAPPEARS
	
