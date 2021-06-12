# This class handles inventory operation
# Can implement bin, shop, chest or exchange between players
extends Node

class_name InventoryContainer

export var objects = [] # List of object in the inventory

export var num_column = 1 # Bin: 1 Shop: 3 
export var num_row = 1
export var unique_id = 46896

var tileStart = Vector2(2, 1)

var money:int = 0

func _ready():
	pass

func setItem(index:int, object) -> bool:
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

func getPrice(item_id:int):
	if item_id >= 0 and item_id < prices.size():
		return prices[item_id]
	else:
		return 0
