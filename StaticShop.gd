extends StaticBody

export var mObjects = []
export var num_column = 3
export var num_row = 1
var isShop = true
var total = 0

var tileStart = Vector2(2, 1)

var prices = [
	0,
	1, # grass
	10, # green fruit
	15, # yellow fruit
	10, # red fruit
	75, # turtle
	50, # blue fish
	5, # seed
	5 # seed 
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

func _on_Area_body_entered(body):
	print("Openning Shop")
	body.get_parent().get_parent()._on_chestOpenned(self)
	# TODO: if userWAllter == null display something to tell the user...
	
func closeChest():
	userWallet.money += total
	mObjects.clear()
	total = 0

func update_total():
	total = 0
	for object in mObjects:
		if object != null:
			total += getPrice(object.id)
	print("Total: ", total)

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
