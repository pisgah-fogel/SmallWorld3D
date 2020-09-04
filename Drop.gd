extends Spatial

var active = false
var mItem = null setget setItem

func _ready():
	var Item = load("res://Item.gd")
	var item = Item.new()
	item.id = Item._id.ID_FISHINGROT
	item.name = Item._name[item.id]
	setItem(item)
	
func setItem(item):
	mItem = item
	active = true

func _on_Area_body_entered(body):
	if active and mItem:
		active = false
		body.get_parent().get_parent().receiveObject(mItem, self)
		var level = get_tree().get_root().get_node("TestScene").notify("You get an "+mItem.name)

func canRemoveObject(obj):
	active = false
	queue_free()
