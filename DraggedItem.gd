extends Sprite

export(int) var index = 0 setget setIndex

func setIndex(i):
	index = i
	update()

func update():
	self.frame = index

func _ready():
	update()
