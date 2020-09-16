extends CanvasLayer

const Item = preload("res://Item.gd")

onready var mTileMap = $Control/TileMap
onready var mControl = $Control

var mItemsTosell = []

func addRandomItem():
	var buff = Item.new()
	buff.id = randi()%20
	buff.name = Item._name[buff.id]
	
	var prize = randi()%80 + 20
	
	mItemsTosell.append([buff, prize])

func _ready():
	if mItemsTosell.size() == 0:
		addRandomItem()
		addRandomItem()
		addRandomItem()
		addRandomItem()
		update_display()

const Node2DItem = preload("res://Node2DItem.tscn")
var listChilds = []
func update_display():
	for child in listChilds:
		child.queue_free()
	listChilds.clear()
	
	var y_pos = 0
	var y_tile = 1
	for item in mItemsTosell:
		mTileMap.set_cell(3, y_tile, 23)
		mTileMap.set_cell(4, y_tile, 24)
		mTileMap.set_cell(5, y_tile, 24)
		mTileMap.set_cell(6, y_tile, 24)
		mTileMap.set_cell(7, y_tile, 25)
		var tmp = Node2DItem.instance()
		tmp.get_node("ItemName").text = item[0].name
		tmp.get_node("ItemPrize").text = str(item[1])
		tmp.get_node("ItemSprite").frame = item[0].id
		tmp.global_position.y = y_pos
		mControl.add_child(tmp)
		y_pos += 188/2
		y_tile += 1
