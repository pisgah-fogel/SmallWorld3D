extends Sprite

var mActive = preload("res://gfx/choice_active.png")
var mInactive = preload("res://gfx/choice_inactive.png")
onready var mLabel = $Label

export var text:String = "" setget setText

func setText(newText):
	text = newText
	if mLabel:
		mLabel.text = text

func setActive(value):
	if value:
		set_texture(mActive)
	else:
		set_texture(mInactive)

