extends StaticBody

export var mObjects = []
export var num_column = 3
export var num_row = 1
var isShop = true
var total = 0
var shop_value = 0 # total value of everything in the shop

var tileStart = Vector2(2, 1)

var prices = [
	0,
	1, # grass
	10, # green fruit
	15, # yellow fruit
	10, # red fruit
	15, # turtle
	10, # blue fish
	5, # seed
	5, # seed
	5, # seed
	5, # seed
	10, # Turnip
	30, # Green Melon
	35, # Yellow Melon
	15, # Tomatto
	20, # Orange
	15, # Grape
	10, # Sunflower
	10, # Strawberry
	150, # Fishing Rot
	200, # Garden
	1 # Present
	]

var userWallet = null setget setUserWallet
func setUserWallet(wallet):
	print("Shop::setUserWallet")
	userWallet = wallet
	
func getPrice(item_id:int):
	if item_id >= 0 and item_id < prices.size():
		return prices[item_id]
	else:
		return 0

func addItemsToChest():
	var tmp = Item.new()
	tmp.id = Item._id.ID_FISHINGROT
	tmp.name = Item._name[tmp.id]
	mObjects.push_back(tmp)
	# TODO: sell something else ?

func _on_Area_body_entered(body):
	print("Openning Shop")
	addItemsToChest()
	update_shopValue()
	body.get_parent().get_parent()._on_chestOpenned(self)
	# TODO: if userWAllter == null display something to tell the user...
	
func closeChest():
	userWallet.money += total
	mObjects.clear()
	total = 0

func update_shopValue():
	shop_value = 0
	for object in mObjects:
		if object != null:
			shop_value += getPrice(object.id)

func update_total():
	total = -shop_value
	for object in mObjects:
		if object != null:
			total += getPrice(object.id)

func setItem(index:int, object):
	if index < 0:
		return false
	elif index < mObjects.size():
		mObjects[index] = object
		update_total()
		return true
	elif index < num_column*num_row:
		mObjects.append(object)
		update_total()
		return true
	else:
		return false
