extends Spatial

var mGift = null
var giftReceived = false

const Drop = preload("res://Drop.tscn")

func _ready():
	mGift = Drop.instance()
	add_child(mGift)
	mGift.global_transform.origin = Vector3(-19.559, 0.509, 5.943)
	mGift.connect("tree_exiting", self, "_gift_received")

func _gift_received():
	giftReceived = true

func save(save_game: Resource):
	save_game.data["TestIsland_fishingRot_gift"] = giftReceived

func load(save_game: Resource):
	if "TestIsland_fishingRot_gift" in save_game.data:
		giftReceived = save_game.data["TestIsland_fishingRot_gift"]
		if giftReceived:
			mGift.queue_free()
