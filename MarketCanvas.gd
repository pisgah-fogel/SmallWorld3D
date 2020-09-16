extends CanvasLayer

const Item = preload("res://Item.gd")

onready var mTileMap = $Control/TileMap
onready var mControl = $Control

const hand_open = preload("res://gfx/hand_open.png")
const hand_close = preload("res://gfx/hand_close.png")
export(Vector2) var hand_offset =  Vector2(50, 40)

var mItemsTosell = []

func addRandomItem():
	var buff = Item.new()
	buff.id = randi()%20
	buff.name = Item._name[buff.id]
	
	var prize = randi()%80 + 20
	
	mItemsTosell.append([buff, prize])

func _ready():
	get_tree().get_root().connect("size_changed", self, "_size_changed")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(hand_close, Input.CURSOR_ARROW, hand_offset)
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

var selection = null
func _input(event):
	if event is InputEventMouseButton:
		get_tree().set_input_as_handled()
		if event.button_index == BUTTON_LEFT and event.pressed:
			if selection != null:
				print("Bought ", selection[0].name, " for ", selection[1])
			
	if event is InputEventMouseMotion:
		get_tree().set_input_as_handled()
		var pos = event.global_position  - offset
		var tmp = (pos - mTileMap.global_position)/mTileMap.scale
		tmp = tmp/mTileMap.cell_size
		var ix = int(tmp.x)
		var iy = int(tmp.y)
		if ix == 7 and iy > 0 and iy <= mItemsTosell.size():
			Input.set_custom_mouse_cursor(hand_open, Input.CURSOR_ARROW, hand_offset)
			selection = mItemsTosell[iy -1]
		else:
			Input.set_custom_mouse_cursor(hand_close, Input.CURSOR_ARROW, hand_offset)
			selection = null

func update_placing():
	offset.y = mControl.get_viewport_rect().size.y-600
	offset.x = mControl.get_viewport_rect().size.x/2-500

func _size_changed():
	update_placing()
