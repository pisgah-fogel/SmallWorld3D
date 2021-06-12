extends CanvasLayer

onready var mBackground = $Control/Background
onready var mItems = $Control/Items
onready var mDraggedItem = $Control/DraggedItem
onready var mMoneyLabel = $Control/MoneyLabel
onready var mControl = $Control
onready var mTotalLabel = $Control/TotalLabel

export(int) var num_column = 5
export(int) var num_row = 2
export var tileStart = Vector2(2, 4)
export(int) var chest_tile = 1
export(int) var shop_tile = 2
export(int) var bin_tile = 3

const hand_open = preload("res://gfx/hand_open.png")
const hand_close = preload("res://gfx/hand_close.png")
export(Vector2) var hand_offset =  Vector2(50, 40)

var apparition : bool = false # Shows up smoothly

var mChest = null setget setChest
func setChest(newchest):
	mChest = newchest
	create_chest_background()
	update_mItems()

var mUserWallet = null setget setUserWallet
func setUserWallet(wallet):
	mUserWallet = wallet
	if mMoneyLabel != null and mUserWallet != null:
		mMoneyLabel.text = str(mUserWallet.money)

# Contains all the objects from the user
var mObjects = [] setget setInventoryList # Contains all the objects from the user
func setInventoryList(list):
	mObjects = list
	update_mItems()

func _ready():
	# Smooth apparition
	apparition = true
	mControl.modulate.a = 0.0

	# Set mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.set_custom_mouse_cursor(hand_open, Input.CURSOR_ARROW, hand_offset)

	# Setup UI graphics
	reset_drafting_sprite()
	update_placing()

	# Responssive design
	var _e = get_tree().get_root().connect("size_changed", self, "_size_changed")

func _process(delta):
	if apparition:
		if mControl.modulate.a < 0.9:
			mControl.modulate.a += delta*4.0
		else:
			mControl.modulate.a = 1.0
			apparition = false

func _size_changed():
	update_placing()

##################### USER INTERFACE ###########################

func create_chest_background():
	"""
	Create the Chest background
	"""
	if mChest!=null:
		for row in range(mChest.num_row):
			for col in range(mChest.num_column):
				var tt = chest_tile
				if mChest.get("isBin"):
					tt = bin_tile
				elif mChest.get("isShop"):
					tt = shop_tile
				mBackground.set_cell(mChest.tileStart.x + col, mChest.tileStart.y + row, tt)
	
func reset_drafting_sprite():
	"""
	Set the sprite which follow the mouse invisible
	"""
	mDraggedItem.index = 0
	mDraggedItem.visible = false

func update_placing():
	"""
	Set the entire GUI in the middle of the screen (should be called when resizing)
	"""
	offset.y = mControl.get_viewport_rect().size.y-600
	offset.x = mControl.get_viewport_rect().size.x/2-500

func update_drafting_sprite(i:int, object):
	"""
	Set which sprite should follow the user's cursor
	"""
	if i < object.mObjects.size() and i >= 0:
		if object.mObjects[i] != null:
			mDraggedItem.position = mControl.get_global_mouse_position()
			mDraggedItem.visible = true
			mDraggedItem.index = object.mObjects[i].id
		else:
			reset_drafting_sprite()

func update_mItems():
	"""
	Populate the inventory foreground
	"""
	var count = 0

	assert(mObjects and mItems != null and is_instance_valid(mItems))

	# User's inventory
	for item in mObjects:
		var sprite_id = -1
		if item != null:
			sprite_id = item.id
		var cell_x = count%num_column + tileStart.x
		var cell_y = count/num_column + tileStart.y
		mItems.set_cell(cell_x, cell_y, sprite_id)
		count += 1

	# Chest
	if mChest:
		count = 0
		for i in range(mChest.num_column*mChest.num_row):
			var sprite_id = -1 # Default empty cell
			var item = null
			if i < mChest.mObjects.size():
				item = mChest.mObjects[i]
				if item != null:
					sprite_id = item.id
			var cell_x = i%mChest.num_column + mChest.tileStart.x
			var cell_y = i/mChest.num_column + mChest.tileStart.y
			mItems.set_cell(cell_x, cell_y, sprite_id)
			count += 1

################################################################

func is_inside_inventory(ix, iy, object):
	var minx = object.tileStart.x
	var maxx = minx + object.num_column
	var miny = object.tileStart.y
	var maxy = miny + object.num_row
	if ix <= maxx and iy <= maxy and ix >= minx and iy >= miny:
		return true
	return false

func mouse_to_mItems_relative(pos):
	var tmp = (pos - mItems.global_position)/mItems.scale + Vector2(100,100)*mItems.cell_size
	tmp = tmp/mItems.cell_size
	return tmp - Vector2(100, 100)

func _input(event):
	if event is InputEventMouseButton:
		get_tree().set_input_as_handled()
		if event.button_index == BUTTON_LEFT and event.pressed:
			start_drag_sprite(event.global_position  - offset)
		elif event.button_index == BUTTON_LEFT and not event.pressed:
			end_drag_sprite(event.global_position  - offset)
	if event is InputEventMouseMotion:
		follow_mouse(event)
		get_tree().set_input_as_handled()
		
	#if event.is_action_pressed("ui_left"):
	#	get_tree().set_input_as_handled()
		# TODO move selection ?
		# ...

func follow_mouse(event):
	if originalContainer != null:
		getDraggedItem().visible = true
		getDraggedItem().position = event.global_position - offset

###################################### START DRAG #########################################
var originalPos = 0
var originalContainer = null # if it is not null = we are dragging an object

func getDraggedItem():
	return originalContainer.mObjects[originalPos]

func abord_draft_give_object_back():
	# Object never moved from originalContainer
	originalContainer = null
	originalPos = 0
	Input.set_custom_mouse_cursor(hand_open, Input.CURSOR_ARROW, hand_offset)
	reset_drafting_sprite()
	update_mItems()

func pickup_in(container, pos_sel):
	"""
	Move an object from a container (at index pos_sel) to a temporary variable
	"""
	Input.set_custom_mouse_cursor(hand_close, Input.CURSOR_ARROW, hand_offset)
	originalContainer = container
	originalPos = pos_sel
	update_drafting_sprite(originalPos, originalContainer)
	update_mItems()

func start_drag_sprite(pos):
	if originalContainer!=null:
		abord_draft_give_object_back() #  TODO: Cleanup ? Is this code usefull
	var tmp = mouse_to_mItems_relative(pos)
	var ix:int = tmp.x
	var iy:int = tmp.y
	if is_inside_inventory(ix, iy, self):
		var pos_sel = (ix-tileStart.x) + (iy-tileStart.y)*num_column
		originChest = false
		if pos_sel < 0:
			abord_draft()
		elif pos_sel < mObjects.size() and mObjects[pos_sel] != null:
			pickup_in(self, pos_sel)
	elif mChest != null and is_inside_inventory(ix, iy, mChest): # valid coordinates ?
		var pos_sel = (ix-mChest.tileStart.x) + (iy-mChest.tileStart.y)*mChest.num_column
		originChest = true
		if pos_sel < 0:
			abord_draft()
		elif pos_sel < mChest.mObjects.size() and mChest.mObjects[pos_sel] != null:
			pickup_in(mChest, pos_sel)
	else:
		abord_draft()
	
	if mChest and mChest.get("isShop"): # update shop
		if mChest.total == 0:
			mTotalLabel.text = ""
		elif mChest.total > 0:
			mTotalLabel.text = "+ " + str(mChest.total)
		else:
			mTotalLabel.text = "- " + str(abs(mChest.total))
###################################### END DRAG #########################################

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

func abord_drop():
	if originChest:
		mChest.setItem(originalPos, draggingObj)
	else:
		mObjects[originalPos] = draggingObj

func drop_in(container, pos_sel_bis):
	if container.get("isBin"):
		originalPos = 0
		draggingObj = null # removing object
	elif pos_sel_bis < 0:
		abord_drop()
	elif pos_sel_bis < container.mObjects.size() and container.mObjects[pos_sel_bis] != null:
		# Switch Items
		var buff = draggingObj
		draggingObj = container.mObjects[pos_sel_bis]
		abord_drop()
		container.setItem(pos_sel_bis, buff)
	elif pos_sel_bis < container.mObjects.size() and container.mObjects[pos_sel_bis] == null:
		# remplace null item with this one
		container.setItem(pos_sel_bis, draggingObj)
	elif pos_sel_bis >= container.mObjects.size() and pos_sel_bis < container.num_column*container.num_row:
		# Add at the end of the list
		container.setItem(pos_sel_bis, draggingObj)
	else:
		abord_drop()

func end_drag_sprite(pos):
	reset_drafting_sprite()
	if not dragging:
		return
	dragging = false
	Input.set_custom_mouse_cursor(hand_open, Input.CURSOR_ARROW, hand_offset)
	
	var tmp = mouse_to_mItems_relative(pos)
	var ix:int = tmp.x
	var iy:int = tmp.y
	if is_inside_inventory(ix, iy, self): # valid coordinates ?
		if mChest and mChest.has_method("canGetObject") and not mChest.canGetObject():
			abord_drop()
		else:
			var pos_sel_bis = (ix-tileStart.x) + (iy-tileStart.y)*num_column
			drop_in(self, pos_sel_bis)
	elif mChest != null and is_inside_inventory(ix, iy, mChest):
		var pos_sel_bis = (ix-mChest.tileStart.x) + (iy-mChest.tileStart.y)*mChest.num_column
		drop_in(mChest, pos_sel_bis)
	else:
		abord_drop()
	originalPos = 0
	draggingObj = null
	update_mItems()
	
	if mChest and mChest.get("isShop"): # update shop
		if mChest.total == 0:
			mTotalLabel.text = ""
		elif mChest.total > 0:
			mTotalLabel.text = "+ " + str(mChest.total)
		else:
			mTotalLabel.text = "- " + str(abs(mChest.total))
