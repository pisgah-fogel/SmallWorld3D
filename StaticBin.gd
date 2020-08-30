extends StaticBody


export var mObjects = []
export var num_column = 1
export var num_row = 1
var isBin = true

var tileStart = Vector2(2, 1)

func _on_Area_body_entered(body):
	body.get_parent().get_parent()._on_chestOpenned(self)

func closeChest():
	pass
